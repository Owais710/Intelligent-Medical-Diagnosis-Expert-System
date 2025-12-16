# 🩺 Intelligent Medical Diagnosis Expert System (Prolog)

An **Intelligent Medical Diagnosis Expert System** implemented in **Prolog** that analyzes patient symptoms, estimates disease likelihood using weighted rules, prioritizes severity, and provides treatment and preventive recommendations with clear justifications.

> ⚠️ **Disclaimer:** This system is for educational and academic purposes only. It is **not a substitute for professional medical diagnosis or treatment**.

---

## 📌 Features

- ✅ Symptom-based diagnosis using **weighted associations**
- ✅ Supports multiple diseases with **severity prioritization**
- ✅ Calculates **confidence percentages** for each diagnosis
- ✅ Provides:
  - Treatment recommendations
  - Preventive measures
  - Explanation/justification for the diagnosis
- ✅ Outputs results sorted by:
  1. Confidence (primary)
  2. Disease severity (tie-breaker)
- ✅ Clean, user-friendly output format

---

## 🧠 Diseases Covered

| Disease      | Severity  |
|---------------|-----------|
| COVID-19      | Severe    |
| Influenza     | Moderate  |
| Pneumonia     | Severe    |
| UTI           | Moderate  |

---

## 🧾 Symptoms Considered

- fever
- cough
- sore_throat
- shortness_of_breath
- headache
- fatigue
- loss_of_smell
- nausea
- vomiting
- diarrhea
- painful_urination
- abdominal_pain
- chest_pain

---

## ⚙️ How the System Works

1. **Symptom–Disease Associations**
   - Each symptom has a **weight** indicating its importance for a disease.

2. **Confidence Calculation**
   - Confidence = (matched symptom weight / total disease weight) × 100

3. **Diagnosis Ranking**
   - Higher confidence dominates
   - Severity acts as a tie-breaker

4. **Justification Engine**
   - Lists matched symptoms
   - Highlights missing important symptoms (high → low priority)
  
## 🏗️ Code Structure

- Symptoms & Diseases Definitions
- Severity Mapping
- Weighted Associations
- Confidence & Justification Engine
- Diagnosis & Ranking Logic
- Pretty Output Formatter

## 📚 Educational Use Cases

- Expert systems coursework
- AI in healthcare demonstrations
- Rule-based reasoning examples
- Prolog knowledge representation practice
