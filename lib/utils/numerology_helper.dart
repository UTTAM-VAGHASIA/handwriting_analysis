class NumerologyResult {
  final int finalNumber;
  final List<MapEntry<String, int>> letterBreakdown;
  final List<String> calculationSteps;

  NumerologyResult({
    required this.finalNumber,
    required this.letterBreakdown,
    required this.calculationSteps,
  });
}

class NumerologyHelper {
  // Chaldean system mapping (User provided)
  static final Map<String, int> _letterValues = {
    'a': 1,
    'i': 1,
    'j': 1,
    'q': 1,
    'y': 1,
    'b': 2,
    'k': 2,
    'r': 2,
    'c': 3,
    'g': 3,
    'l': 3,
    's': 3,
    'd': 4,
    'm': 4,
    't': 4,
    'e': 5,
    'h': 5,
    'n': 5,
    'x': 5,
    'u': 6,
    'v': 6,
    'w': 6,
    'o': 7,
    'z': 7,
    'f': 8,
    'p': 8,
  };

  static NumerologyResult calculateNameNumber(String name) {
    if (name.isEmpty) {
      return NumerologyResult(
        finalNumber: 0,
        letterBreakdown: [],
        calculationSteps: [],
      );
    }

    String cleanName = name.toLowerCase().replaceAll(RegExp(r'[^a-z]'), '');
    List<MapEntry<String, int>> breakdown = [];
    int sum = 0;

    for (int i = 0; i < cleanName.length; i++) {
      String char = cleanName[i];
      if (_letterValues.containsKey(char)) {
        int val = _letterValues[char]!;
        breakdown.add(MapEntry(char.toUpperCase(), val));
        sum += val;
      }
    }

    List<String> steps = [];
    // Initial sum step
    steps.add('${breakdown.map((e) => e.value).join(' + ')} = $sum');

    int finalNum = _reduceNumber(sum, steps);

    return NumerologyResult(
      finalNumber: finalNum,
      letterBreakdown: breakdown,
      calculationSteps: steps,
    );
  }

  static int _reduceNumber(int number, List<String> steps) {
    // Master numbers are not reduced
    if (number == 11 || number == 22 || number == 33) {
      return number;
    }

    // Reduce to single digit
    while (number > 9 && number != 11 && number != 22 && number != 33) {
      int tempSum = 0;
      String numStr = number.toString();
      List<String> digits = [];

      for (int i = 0; i < numStr.length; i++) {
        int digit = int.parse(numStr[i]);
        tempSum += digit;
        digits.add(digit.toString());
      }

      steps.add('${digits.join(' + ')} = $tempSum');
      number = tempSum;
    }

    return number;
  }
}
