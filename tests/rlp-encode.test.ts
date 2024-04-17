import { Cl } from "@stacks/transactions";
import { describe, expect, it } from "vitest";

const accounts = simnet.getAccounts();
const address1 = accounts.get("wallet_1")!;

describe("RLP Encoding Tests", () => {
  it("encodes a simple string 'dog'", () => {
    const { result } = simnet.callReadOnlyFn("rlp-encode", "rlp-encode", [Cl.stringAscii("dog")], address1);
    expect(result).toEqual([0x83, 'd', 'o', 'g']);
  });

  it("encodes a list containing the strings 'cat' and 'dog'", () => {
    const { result } = simnet.callReadOnlyFn("rlp-encode", "rlp-encode", [Cl.list([Cl.stringAscii("cat"), Cl.stringAscii("dog")])], address1);
    expect(result).toEqual([0xc8, 0x83, 'c', 'a', 't', 0x83, 'd', 'o', 'g']);
  });

  it("encodes an empty string", () => {
    const { result } = simnet.callReadOnlyFn("rlp-encode", "rlp-encode", [Cl.stringAscii("")], address1);
    expect(result).toEqual([0x80]);
  });

  it("encodes an empty list", () => {
    const { result } = simnet.callReadOnlyFn("rlp-encode", "rlp-encode", [Cl.list([])], address1);
    expect(result).toEqual([0xc0]);
  });

  it("encodes the integer 0 as an empty string", () => {
    const { result } = simnet.callReadOnlyFn("rlp-encode", "rlp-encode", [Cl.uint(0)], address1);
    expect(result).toEqual([0x80]);
  });

  it("encodes the integer 0 with explicit byte", () => {
    const { result } = simnet.callReadOnlyFn("rlp-encode", "rlp-encode", [Cl.bufferFromAscii("\x00")], address1);
    expect(result).toEqual([0x00]);
  });

  it("encodes the integer 15", () => {
    const { result } = simnet.callReadOnlyFn("rlp-encode", "rlp-encode", [Cl.bufferFromAscii("\x0f")], address1);
    expect(result).toEqual([0x0f]);
  });

  it("encodes the integer 1024", () => {
    const { result } = simnet.callReadOnlyFn("rlp-encode", "rlp-encode", [Cl.bufferFromAscii("\x04\x00")], address1);
    expect(result).toEqual([0x82, 0x04, 0x00]);
  });

  it("encodes a set theoretical representation of three", () => {
    const { result } = simnet.callReadOnlyFn("rlp-encode", "rlp-encode", [Cl.list([Cl.list([]), Cl.list([Cl.list([])]), Cl.list([Cl.list([]), Cl.list([Cl.list([])])])])], address1);
    expect(result).toEqual([0xc7, 0xc0, 0xc1, 0xc0, 0xc3, 0xc0, 0xc1, 0xc0]);
  });
});
