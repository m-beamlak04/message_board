const {readFileSync} = require('node:fs');
const {test, before, beforeEach, after} = require('node:test');

const {
    initializeTestEnvironment, assertFails, assertSucceeds,
} = require('@firebase/rules-unit-testing');

const {
    doc, getDoc, setDoc, updateDoc, deleteDoc, serverTimestamp,
} = require('firebase/firestore');

let testEnv;

before(async () => {
    testEnv = await initializeTestEnvironment({
        projectId: 'message-board-a2cff', firestore: {
            host: '127.0.0.1', port: 8080, rules: readFileSync('../firestore.rules', 'utf8'),
        },
    });
});

beforeEach(async () => {
    await testEnv.clearFirestore();
});

test('Signed-out users cannot read messages', async () => {
    const db = testEnv.unauthenticatedContext().firestore();
    await assertFails(getDoc(doc(db, 'messages', 'test-message')));
});

test('User B cannot update User A message', async () => {
    const userA = testEnv.authenticatedContext('user-a').firestore();
    const userB = testEnv.authenticatedContext('user-b').firestore();

    const messageRef = doc(userA, 'messages', 'ownership-test');

    // Create a message as User A.
    await assertSucceeds(setDoc(messageRef, {
        text: 'Original message',
        authorUid: 'user-a',
        authorName: 'User A',
        createdAt: serverTimestamp(),
        editedAt: null,
    }));

    // User B attempts to edit User A's message.
    await assertFails(updateDoc(doc(userB, 'messages', 'ownership-test'), {
        text: 'Unauthorized edit', editedAt: serverTimestamp(),
    }));
});


test('User B cannot forge User A ownership', async () => {
    const userB = testEnv.authenticatedContext('user-b').firestore();

    await assertFails(setDoc(doc(userB, 'messages', 'forged-message'), {
        text: 'Pretending to be User A',
        authorUid: 'user-a',
        authorName: 'User A',
        createdAt: serverTimestamp(),
        editedAt: null,
    }));
});


test('Correct author can create, read, update, and delete', async () => {
    const userA = testEnv.authenticatedContext('user-a').firestore();
    const messageRef = doc(userA, 'messages', 'author-crud-test');

    // CREATE
    await assertSucceeds(setDoc(messageRef, {
        text: 'Original message',
        authorUid: 'user-a',
        authorName: 'User A',
        createdAt: serverTimestamp(),
        editedAt: null,
    }));

    // READ
    const message = await assertSucceeds(getDoc(messageRef));
    if (!message.exists()) {
        throw new Error('Created message was not found');
    }

    // UPDATE
    await assertSucceeds(updateDoc(messageRef, {
        text: 'Updated message', editedAt: serverTimestamp(),
    }));

    // DELETE
    await assertSucceeds(deleteDoc(messageRef));
});

after(async () => {
    if (testEnv) {
        await testEnv.cleanup();
    }
});
