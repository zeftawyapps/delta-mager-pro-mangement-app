const regex = /^(?:\+2|002)?01[0125][0-9]{8}$/;
const testNumbers = [
  '01120031403',
  '٠١١٢٠٠٣١٤٠٣',
  '+201120031403',
  '00201120031403'
];

function normalizeArabicNumerals(str) {
    const arabicIndic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    const easternArabic = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'];
    
    let normalized = str;
    for (let i = 0; i < 10; i++) {
        normalized = normalized.replace(new RegExp(arabicIndic[i], 'g'), i);
        normalized = normalized.replace(new RegExp(easternArabic[i], 'g'), i);
    }
    return normalized;
}

testNumbers.forEach(num => {
  const norm = normalizeArabicNumerals(num);
  console.log(`Original: ${num} | Normalized: ${norm} | Match: ${regex.test(norm)}`);
});
