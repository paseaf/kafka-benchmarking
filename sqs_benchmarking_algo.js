/**
 *
 * @param {*} Sender
 * @param {*} Receiver
 * @param {*} E
 * @param {*} maxR
 * @param {*} noS
 * @param {*} T
 * @param {*} w
 * @returns
 */
function benchmarkSqsConsistency(Sender, Receiver, E, maxR, noS, T, w) {
  const result = {
    Y: 1,
    H: 1,
    O: 0,
    D: 0,
  };

  // Ensure
  if (!isValidResult(result)) {
    throw Error("Result out of range: ", result);
  }

  return result;
}

/////////// Utils
function isValidResult(result) {
  const { Y, H, O, D } = result;
  const isYValid = isInRangeInclusive(Y, 0, 1);
  const isHValid = isInRangeInclusive(H, 0, 1);
  const isOValid = isInRangeInclusive(O, 0, Number.POSITIVE_INFINITY);
  const isDValue = isInRangeInclusive(D, 0, Number.POSITIVE_INFINITY);

  return isYValid && isHValid && isOValid && isDValue;
}

function isInRangeInclusive(value, min, max) {
  return value >= min && value <= max;
}
