import { Cl } from "@stacks/transactions";
import { describe, expect, it } from "vitest";

const accounts = simnet.getAccounts();
const address1 = accounts.get("wallet_1")!;

function toHex(str:string) {
  var result = '';
  for (var i=0; i<str.length; i++) {
    result += str.charCodeAt(i).toString(16);
  }
  return result;
}

describe("RLP Decoding Tests", () => {
  it("decodes a simple string 'dog'", () => {
    var data  = simnet.callReadOnlyFn("rlp-decode", "decode-item", [Cl.bufferFromHex("83" + toHex("dog") + "00")], address1);
    var item  = simnet.callReadOnlyFn("rlp-decode", "get-item", [data.result], address1);
    var decoded  = simnet.callReadOnlyFn("rlp-decode", "decode-string", [item.result], address1);
    expect(decoded.result).toEqual(Cl.stringAscii("dog"));
  });

  it("decodes a list containing the strings 'cat' and 'dog'", () => {
    var list = simnet.callReadOnlyFn("rlp-decode", "rlp-to-list", [Cl.bufferFromHex("c88363617483646f67")], address1);
    var cat = simnet.callReadOnlyFn("rlp-decode", "rlp-decode-string", [list.result, Cl.uint(0)], address1);
    var dog = simnet.callReadOnlyFn("rlp-decode", "rlp-decode-string", [list.result, Cl.uint(1)], address1);

    expect(cat.result).toEqual(Cl.stringAscii("cat"));
    expect(dog.result).toEqual(Cl.stringAscii("dog"));
  });

  it("decodes an empty string", () => {
    var data = simnet.callReadOnlyFn("rlp-decode", "decode-item", [Cl.bufferFromHex("80")], address1);
    var encoded  = simnet.callReadOnlyFn("rlp-decode", "get-item", [data.result], address1);
    const { result } = simnet.callReadOnlyFn("rlp-decode", "decode-string",  [encoded.result], address1);
    expect(result).toEqual(Cl.stringAscii(""));
  });

  it("decodes an empty list", () => {
    const { result } = simnet.callReadOnlyFn("rlp-decode", "rlp-to-list", [Cl.bufferFromHex("c0")], address1);
    console.log(result)
    expect(result).toBeList([]);
  });

  it("decodes the integer 0 as an empty string", () => {
    var data = simnet.callReadOnlyFn("rlp-decode", "decode-item", [Cl.bufferFromHex("80")], address1);
    var encoded  = simnet.callReadOnlyFn("rlp-decode", "get-item", [data.result], address1);
    const { result } = simnet.callReadOnlyFn("rlp-decode", "decode-uint",  [encoded.result], address1);
    expect(result).toEqual(Cl.uint(0));
  });

  it("decodes the integer 15", () => {
    var data = simnet.callReadOnlyFn("rlp-decode", "decode-item", [Cl.bufferFromHex("0f")], address1);
    var encoded  = simnet.callReadOnlyFn("rlp-decode", "get-item", [data.result], address1);
    const { result } = simnet.callReadOnlyFn("rlp-decode", "decode-uint",  [encoded.result], address1);
    expect(result).toEqual(Cl.uint(15));
  });

  it("decodes the integer 1024", () => {
    var data = simnet.callReadOnlyFn("rlp-decode", "decode-item", [Cl.bufferFromHex("820400")], address1);
    var encoded  = simnet.callReadOnlyFn("rlp-decode", "get-item", [data.result], address1);
    const { result } = simnet.callReadOnlyFn("rlp-decode", "decode-uint",  [encoded.result], address1);
    expect(result).toEqual(Cl.uint(1024));
  });

  // it("decodes a set theoretical representation of three", () => {
  //   const { result } = simnet.callReadOnlyFn("rlp-decode", "rlp-decode", [Cl.bufferFromHex("c7c0c1c0c3c0c1c0")], address1);
  // });

  it("decodes a long string correctly", () => {
    var data = simnet.callReadOnlyFn("rlp-decode", "decode-item", [Cl.bufferFromHex("b8384c6f72656d20697073756d20646f6c6f722073697420616d65742c20636f6e7365637465747572206164697069736963696e6720656c6974")], address1);
    var encoded  = simnet.callReadOnlyFn("rlp-decode", "get-item", [data.result], address1);
    const { result } = simnet.callReadOnlyFn("rlp-decode", "decode-string",  [encoded.result], address1);
    expect(result).toEqual(Cl.stringAscii("Lorem ipsum dolor sit amet, consectetur adipisicing elit"));
  });
});

// describe("RLP Decoding Invalid Tests", () => {
//   const invalidTests = [
//     { name: "int32Overflow", hex: "bf0f000000000000021111" },
//     { name: "int32Overflow2", hex: "ff0f000000000000021111" },
//     { name: "wrongSizeList", hex: "f80180" },
//     { name: "wrongSizeList2", hex: "f80100" },
//     { name: "incorrectLengthInArray", hex: "b9002100dc2b275d0f74e8a53e6f4ec61b27f24278820be3f82ea2110e582081b0565df0" },
//     { name: "randomRLP", hex: "f861f83eb9002100dc2b275d0f74e8a53e6f4ec61b27f24278820be3f82ea2110e582081b0565df027b90015002d5ef8325ae4d034df55d4b58d0dfba64d61ddd17be00000b9001a00dae30907045a2f66fa36f2bb8aa9029cbb0b8a7b3b5c435ab331" },
//     { name: "bytesShouldBeSingleByte00", hex: "8100" },
//     { name: "bytesShouldBeSingleByte01", hex: "8101" },
//     { name: "bytesShouldBeSingleByte7F", hex: "817F" },
//     { name: "leadingZerosInLongLengthArray1", hex: "b90040000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f202122232425262728292a2b2c2d2e2f303132333435363738393a3b3c3d3e3f" },
//     { name: "leadingZerosInLongLengthArray2", hex: "b800" },
//     { name: "leadingZerosInLongLengthList1", hex: "fb00000040000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f202122232425262728292a2b2c2d2e2f303132333435363738393a3b3c3d3e3f" },
//     { name: "leadingZerosInLongLengthList2", hex: "f800" },
//     { name: "nonOptimalLongLengthArray1", hex: "b81000112233445566778899aabbccddeeff" },
//     { name: "nonOptimalLongLengthArray2", hex: "b801ff" },
//     { name: "nonOptimalLongLengthList1", hex: "f810000102030405060708090a0b0c0d0e0f" },
//     { name: "nonOptimalLongLengthList2", hex: "f803112233" },
//     { name: "emptyEncoding", hex: "" },
//     { name: "lessThanShortLengthArray1", hex: "81" },
//     { name: "lessThanShortLengthArray2", hex: "a0000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e" },
//     { name: "lessThanShortLengthList1", hex: "c5010203" },
//     { name: "lessThanShortLengthList2", hex: "e201020304050607" },
//     { name: "lessThanLongLengthArray1", hex: "ba010000aabbccddeeff" },
//     { name: "lessThanLongLengthArray2", hex: "b840ffeeddccbbaa99887766554433221100" },
//     { name: "lessThanLongLengthList1", hex: "f90180" },
//     { name: "lessThanLongLengthList2", hex: "ffffffffffffffffff0001020304050607" }
//   ];

//   invalidTests.forEach(test => {
//     it(`fails decoding on invalid input for ${test.name}`, () => {
//       try {
//         const decode = simnet.callReadOnlyFn("rlp-decode", "rlp-decode", [Cl.bufferFromHex(test.hex)], address1);
//         assert(false)
//       } catch {

//       }
//       // expect(decode.result).toBeErr(Cl.uint(101)); // TODO: update error codes once contracts run
//     });
//   });
// });