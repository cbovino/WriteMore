var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    function adopt(value) { return value instanceof P ? value : new P(function (resolve) { resolve(value); }); }
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : adopt(result.value).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
var __generator = (this && this.__generator) || function (thisArg, body) {
    var _ = { label: 0, sent: function() { if (t[0] & 1) throw t[1]; return t[1]; }, trys: [], ops: [] }, f, y, t, g;
    return g = { next: verb(0), "throw": verb(1), "return": verb(2) }, typeof Symbol === "function" && (g[Symbol.iterator] = function() { return this; }), g;
    function verb(n) { return function (v) { return step([n, v]); }; }
    function step(op) {
        if (f) throw new TypeError("Generator is already executing.");
        while (_) try {
            if (f = 1, y && (t = op[0] & 2 ? y["return"] : op[0] ? y["throw"] || ((t = y["return"]) && t.call(y), 0) : y.next) && !(t = t.call(y, op[1])).done) return t;
            if (y = 0, t) op = [op[0] & 2, t.value];
            switch (op[0]) {
                case 0: case 1: t = op; break;
                case 4: _.label++; return { value: op[1], done: false };
                case 5: _.label++; y = op[1]; op = [0]; continue;
                case 7: op = _.ops.pop(); _.trys.pop(); continue;
                default:
                    if (!(t = _.trys, t = t.length > 0 && t[t.length - 1]) && (op[0] === 6 || op[0] === 2)) { _ = 0; continue; }
                    if (op[0] === 3 && (!t || (op[1] > t[0] && op[1] < t[3]))) { _.label = op[1]; break; }
                    if (op[0] === 6 && _.label < t[1]) { _.label = t[1]; t = op; break; }
                    if (t && _.label < t[2]) { _.label = t[2]; _.ops.push(op); break; }
                    if (t[2]) _.ops.pop();
                    _.trys.pop(); continue;
            }
            op = body.call(thisArg, _);
        } catch (e) { op = [6, e]; y = 0; } finally { f = t = 0; }
        if (op[0] & 5) throw op[1]; return { value: op[0] ? op[1] : void 0, done: true };
    }
};
var _a = require('@openzeppelin/test-environment'), accounts = _a.accounts, contract = _a.contract;
var _b = require('@openzeppelin/test-helpers'), BN = _b.BN, // Big Number support
constants = _b.constants, // Common constants, like the zero address and largest integers
expectEvent = _b.expectEvent, // Assertions for emitted events
expectRevert = _b.expectRevert, // Assertions for transactions that should fail
time = _b.time;
var owner = accounts[0], user1 = accounts[1];
var expect = require('chai').expect;
var timeMachine = require('ganache-time-traveler');
var WriteMore = contract.fromArtifact('WriteMore'); // Loads a compiled contract
describe('Write More', function () {
    return __awaiter(this, void 0, void 0, function () {
        return __generator(this, function (_a) {
            beforeEach(function () {
                return __awaiter(this, void 0, void 0, function () {
                    var _a;
                    return __generator(this, function (_b) {
                        switch (_b.label) {
                            case 0:
                                _a = this;
                                return [4 /*yield*/, WriteMore.new({ from: owner })];
                            case 1:
                                _a.myContract = _b.sent();
                                return [2 /*return*/];
                        }
                    });
                });
            });
            before(function () {
                return __awaiter(this, void 0, void 0, function () {
                    var oldTime, todaysTime, _a;
                    return __generator(this, function (_b) {
                        switch (_b.label) {
                            case 0: return [4 /*yield*/, time.latest()];
                            case 1:
                                oldTime = (_b.sent()).toNumber();
                                todaysTime = Date.now();
                                return [4 /*yield*/, time.increase((todaysTime - oldTime))];
                            case 2:
                                _b.sent();
                                _a = this;
                                return [4 /*yield*/, time.latest()];
                            case 3:
                                _a.updatedTime = (_b.sent()).toNumber();
                                return [2 /*return*/];
                        }
                    });
                });
            });
            // async function resetTime (){
            // }
            it('Deployer can call balance', function () {
                return __awaiter(this, void 0, void 0, function () {
                    var bn, _a, err_1;
                    return __generator(this, function (_b) {
                        switch (_b.label) {
                            case 0:
                                _b.trys.push([0, 2, , 3]);
                                _a = BN.bind;
                                return [4 /*yield*/, this.myContract.getBalance({ from: owner })];
                            case 1:
                                bn = new (_a.apply(BN, [void 0, _b.sent()]))().toString();
                                expect(bn).to.equal("0");
                                return [3 /*break*/, 3];
                            case 2:
                                err_1 = _b.sent();
                                console.log(err_1);
                                return [3 /*break*/, 3];
                            case 3: return [2 /*return*/];
                        }
                    });
                });
            });
            it("Add a user's Commitment- Success", function () {
                return __awaiter(this, void 0, void 0, function () {
                    var submitUser;
                    return __generator(this, function (_a) {
                        switch (_a.label) {
                            case 0: return [4 /*yield*/, this.myContract.initialCommit(this.updatedTime + 87400, { from: user1, value: "20000000000000000" })];
                            case 1:
                                submitUser = _a.sent();
                                expectEvent(submitUser, "committed", { _from: user1 });
                                return [2 /*return*/];
                        }
                    });
                });
            });
            it("Add a user's commitment - No gas revert", function () {
                return __awaiter(this, void 0, void 0, function () {
                    return __generator(this, function (_a) {
                        switch (_a.label) {
                            case 0: return [4 /*yield*/, expectRevert(this.myContract.initialCommit(this.updatedTime + 87400, { from: user1 }), "Sent too much or too little at stake")];
                            case 1:
                                _a.sent();
                                return [2 /*return*/];
                        }
                    });
                });
            });
            it("Add a user's commitment - Already has a commitment", function () {
                return __awaiter(this, void 0, void 0, function () {
                    return __generator(this, function (_a) {
                        switch (_a.label) {
                            case 0: return [4 /*yield*/, this.myContract.initialCommit(this.updatedTime + 87400, { from: user1, value: "20000000000000000" })];
                            case 1:
                                _a.sent();
                                return [4 /*yield*/, expectRevert(this.myContract.initialCommit(this.updatedTime + 87400, { from: user1 }), "Already has a commitment")];
                            case 2:
                                _a.sent();
                                return [2 /*return*/];
                        }
                    });
                });
            });
            it("Update a commitment - success - no missedDays ", function () {
                return __awaiter(this, void 0, void 0, function () {
                    var test2, teste;
                    return __generator(this, function (_a) {
                        switch (_a.label) {
                            case 0: return [4 /*yield*/, this.myContract.initialCommit(this.updatedTime + 604800, { from: user1, value: "20000000000000000" })];
                            case 1:
                                _a.sent();
                                return [4 /*yield*/, time.increase(86399)];
                            case 2:
                                _a.sent();
                                return [4 /*yield*/, time.latest()];
                            case 3:
                                test2 = (_a.sent()).words[0];
                                return [4 /*yield*/, this.myContract.updateCommitment({ from: user1 })];
                            case 4:
                                _a.sent();
                                return [4 /*yield*/, this.myContract.returnCommitmentDetails({ from: user1 })
                                    //latest submit date worked
                                ];
                            case 5:
                                teste = _a.sent();
                                //latest submit date worked
                                expect(teste.receipt.logs[0].args.latestSubmitDate.words[0]).to.equal(test2);
                                //no days have been missed
                                expect(teste.receipt.logs[0].args.daysMissed.words[0]).to.equal(0);
                                return [2 /*return*/];
                        }
                    });
                });
            });
            it("Update a commitment - success - 1 Missed Days ", function () {
                return __awaiter(this, void 0, void 0, function () {
                    var test2, teste;
                    return __generator(this, function (_a) {
                        switch (_a.label) {
                            case 0: return [4 /*yield*/, this.myContract.initialCommit(this.updatedTime + 604800, { from: user1, value: "20000000000000000" })];
                            case 1:
                                _a.sent();
                                return [4 /*yield*/, time.increase(96401)];
                            case 2:
                                _a.sent();
                                return [4 /*yield*/, time.latest()];
                            case 3:
                                test2 = (_a.sent()).words[0];
                                return [4 /*yield*/, this.myContract.updateCommitment({ from: user1 })];
                            case 4:
                                _a.sent();
                                return [4 /*yield*/, this.myContract.returnCommitmentDetails({ from: user1 })
                                    //latest submit date worked
                                ];
                            case 5:
                                teste = _a.sent();
                                //latest submit date worked
                                expect(teste.receipt.logs[0].args.latestSubmitDate.words[0]).to.equal(test2);
                                //no days have been missed
                                expect(teste.receipt.logs[0].args.daysMissed.words[0]).to.equal(1);
                                return [2 /*return*/];
                        }
                    });
                });
            });
            xit("Update a commitment - success - Last Days ", function () {
                return __awaiter(this, void 0, void 0, function () {
                    var test, test2, teste;
                    return __generator(this, function (_a) {
                        switch (_a.label) {
                            case 0: return [4 /*yield*/, time.latest()];
                            case 1:
                                test = _a.sent();
                                return [4 /*yield*/, this.myContract.initialCommit(1618264142, { from: user1, value: "20000000000000000" })];
                            case 2:
                                _a.sent();
                                return [4 /*yield*/, time.increase(86399)];
                            case 3:
                                _a.sent();
                                return [4 /*yield*/, time.latest()];
                            case 4:
                                test2 = (_a.sent()).words[0];
                                return [4 /*yield*/, this.myContract.updateCommitment({ from: user1 })];
                            case 5:
                                _a.sent();
                                return [4 /*yield*/, this.myContract.returnCommitmentDetails({ from: user1 })
                                    //latest submit date worked
                                ];
                            case 6:
                                teste = _a.sent();
                                //latest submit date worked
                                expect(teste.receipt.logs[0].args.latestSubmitDate.words[0]).to.equal(test2);
                                //no days have been missed
                                expect(teste.receipt.logs[0].args.daysMissed.words[0]).to.equal(0);
                                return [2 /*return*/];
                        }
                    });
                });
            });
            it("Update a commitment - error - 6hour buffer ", function () {
                return __awaiter(this, void 0, void 0, function () {
                    var test, test2;
                    return __generator(this, function (_a) {
                        switch (_a.label) {
                            case 0: return [4 /*yield*/, time.latest()];
                            case 1:
                                test = _a.sent();
                                return [4 /*yield*/, this.myContract.initialCommit(1618264142, { from: user1, value: "20000000000000000" })];
                            case 2:
                                _a.sent();
                                return [4 /*yield*/, time.increase(20000)];
                            case 3:
                                _a.sent();
                                return [4 /*yield*/, time.latest()];
                            case 4:
                                test2 = (_a.sent()).words[0];
                                return [4 /*yield*/, expectRevert(this.myContract.updateCommitment({ from: user1 }), "6 Hour buffer between next submission")];
                            case 5:
                                _a.sent();
                                return [2 /*return*/];
                        }
                    });
                });
            });
            it("Update a commitment - error - Bad Address ", function () {
                return __awaiter(this, void 0, void 0, function () {
                    return __generator(this, function (_a) {
                        switch (_a.label) {
                            case 0: return [4 /*yield*/, expectRevert(this.myContract.updateCommitment({ from: user1 }), "No commitment for address")];
                            case 1:
                                _a.sent();
                                return [2 /*return*/];
                        }
                    });
                });
            });
            return [2 /*return*/];
        });
    });
});
//# sourceMappingURL=writemore.test.js.map