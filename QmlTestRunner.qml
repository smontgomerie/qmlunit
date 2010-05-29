import Qt 4.7
import "components"
import "scripts/support.js" as Support
import "scripts/qmlunit.js" as QmlUnit

Rectangle {
    id: runner

    property alias totalTests : status.totalTests
    property alias testsRan : status.testsRan
    property alias totalAssertions : status.totalAssertions
    property alias totalFailures : status.totalFailures

    Column {

        anchors.fill: parent

        Banner { id: banner }

        Separator { id: separator }

        Results {
            id: results
            height: parent.height - banner.height - separator.height - status.height
        }

        Status {
            id: status
            state: 'loading'
        }
    }

    function setTimeout(callback, timeout) {
        var obj = Qt.createQmlObject('import Qt 4.7; Timer {running: false; repeat: false; interval: ' + timeout + '}', runner, "setTimeout");
        obj.triggered.connect(callback);
        obj.running = true;

        return obj;
    }

    function clearTimeout(timer) {
        timer.running = false;
        timer.destroy(1);

        return timer;
    }

    function parseInput(input) {
        var folder = input.substring(0, input.lastIndexOf('/'));
        var testCase = input.substring(input.lastIndexOf('/') + 1, input.lastIndexOf('.qml'));

        return {folder: folder, testCase: testCase};
    }

    function testCaseStart(name) {
        var tc = {
            name: name,
            failures: 0,
            tests: [ ]
        };
        results.appendTestCase(tc);
    }

    function testFinished(testName, failures, totalAssertions, assertions) {
        QmlUnit.QUnit.stop();

        testsRan += 1;
        totalFailures += (failures > 0) ? 1 : 0;
        runner.totalAssertions += totalAssertions;

        var test = {
            name: testName,
            failures: failures,
            assertions: assertions
        };

        results.appendTest(test);

        QmlUnit.QUnit.start();
    }

    function registered(tc) {
        totalTests += tc.tests.length;
    }

    Component.onCompleted: {
        QmlUnit.Runner.onTestCaseRegistered = registered;

        var input = parseInput(testSuiteInput);
        Qt.createQmlObject('import Qt 4.7; import "' + input.folder + '"; ' + input.testCase + ' { }', runner, input.testCase);

        QmlUnit.window.setTimeout = runner.setTimeout;
        QmlUnit.window.clearTimeout = runner.clearTimeout;

        QmlUnit.QUnit.moduleStart = testCaseStart;
        QmlUnit.QUnit.testDone = testFinished;

        QmlUnit.onCompleted();

        status.state = 'running';

        QmlUnit.Runner.testCases.each(function(tc){
            QmlUnit.QUnit.module(tc.name, tc.testEnvironment);

            tc.tests.each(function(test){
                if (test.length == 4)
                    QmlUnit.QUnit[test[0]](test[1], test[2], test[3]);
                else
                    QmlUnit.QUnit[test[0]](test[1], test[2]);
            });
        });
    }
}