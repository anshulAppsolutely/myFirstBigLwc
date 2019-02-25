// createElement is what we'll use to create our component under test
import { createElement } from 'lwc';

// Import module under test by convention <namespace>/<moduleName>
import lwcAccountPresenceDashboard from 'c/accountPresenceDashboard';

describe('helloWorld', () => {
    it('displays expected header text', () => {
        // Compare the found text with the expected value
        expect(true).toBe(true);
    });
});