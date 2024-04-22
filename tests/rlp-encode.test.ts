import { Cl } from "@stacks/transactions";
import { describe, expect, it } from "vitest";

const accounts = simnet.getAccounts();
const address1 = accounts.get("wallet_1")!;

describe("RLP Encoding Tests", () => {
  it("encodes a simple string 'dog'", () => {
    const { result } = simnet.callReadOnlyFn("rlp-encode", "encode-string", [Cl.stringAscii("dog")], address1);
    expect(result).toBeBuff(Uint8Array.from([0x83, 'd'.charCodeAt(0), 'o'.charCodeAt(0), 'g'.charCodeAt(0)]))
  });

  it("encodes a list containing the strings 'cat' and 'dog'", () => {
    var cat = simnet.callReadOnlyFn("rlp-encode", "encode-string", [Cl.stringAscii("cat")], address1);
    var dog = simnet.callReadOnlyFn("rlp-encode", "encode-string", [Cl.stringAscii("dog")], address1);
    const { result } = simnet.callReadOnlyFn("rlp-encode", "encode-arr", [Cl.list([cat.result, dog.result])], address1);
    expect(result).toBeBuff(Uint8Array.from([0xc8, 0x83, 'c'.charCodeAt(0), 'a'.charCodeAt(0), 't'.charCodeAt(0), 0x83, 'd'.charCodeAt(0), 'o'.charCodeAt(0), 'g'.charCodeAt(0)]));
  });

  it("encodes an empty string", () => {
    const { result } = simnet.callReadOnlyFn("rlp-encode", "encode-string", [Cl.stringAscii("")], address1);
    expect(result).toBeBuff(Uint8Array.from([0x80]));
  });

  it("encodes an empty list", () => {
    const { result } = simnet.callReadOnlyFn("rlp-encode", "encode-arr", [Cl.list([])], address1);
    expect(result).toBeBuff(Uint8Array.from([0xc0]));
  });

  it("encodes the integer 0", () => {
    const { result } = simnet.callReadOnlyFn("rlp-encode", "encode-uint", [Cl.uint(0)], address1);
    expect(result).toBeBuff(Uint8Array.from([0x00]));
  });

  it("encodes the integer 15", () => {
    const { result } = simnet.callReadOnlyFn("rlp-encode", "encode-uint", [Cl.uint(15)], address1);
    expect(result).toBeBuff(Uint8Array.from([0x0f]));
  });

  it("encodes the integer 1024", () => {
    const { result } = simnet.callReadOnlyFn("rlp-encode", "encode-uint", [Cl.uint(1024)], address1);
    expect(result).toBeBuff(Uint8Array.from([0x82, 0x04, 0x00]));
  });

  // it("encodes a set theoretical representation of three", () => {
  //   const { result } = simnet.callReadOnlyFn("rlp-encode", "encode-string", [Cl.list([Cl.list([]), Cl.list([Cl.list([])]), Cl.list([Cl.list([]), Cl.list([Cl.list([])])])])], address1);
  //   expect(result).toBeBuff(Uint8Array.from([0xc7, 0xc0, 0xc1, 0xc0, 0xc3, 0xc0, 0xc1, 0xc0]));
  // });
});
