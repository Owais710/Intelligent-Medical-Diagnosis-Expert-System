% -----------------------------------------------------------
% Intelligent Medical Diagnosis Expert System
% -----------------------------------------------------------

:- style_check(-singleton).

% -----------------------------------------------------------
% 1. SYMPTOMS
% List of observable symptoms considered by the system
% -----------------------------------------------------------
symptom(fever).
symptom(cough).
symptom(sore_throat).
symptom(shortness_of_breath).
symptom(headache).
symptom(fatigue).
symptom(loss_of_smell).
symptom(nausea).
symptom(vomiting).
symptom(diarrhea).
symptom(painful_urination).
symptom(abdominal_pain).
symptom(chest_pain).

% -----------------------------------------------------------
% 2. DISEASES
% Four diseases considered for diagnosis
% -----------------------------------------------------------
disease(covid19).
disease(influenza).
disease(pneumonia).
disease(uti).

% -----------------------------------------------------------
% 3. DISEASE SEVERITY
% Defines severity levels for prioritization
% -----------------------------------------------------------
disease_severity(covid19, severe).
disease_severity(influenza, moderate).
disease_severity(pneumonia, severe).
disease_severity(uti, moderate).

% Severity numeric mapping for scoring
severity_value(severe, 3).
severity_value(moderate, 2).
severity_value(mild, 1).

% -----------------------------------------------------------
% 4. TREATMENTS
% Suggested treatments for each disease
% -----------------------------------------------------------
treatment(covid19, 'Isolate, rest, stay hydrated, seek medical care if breathing worsens; antivirals/supportive care').
treatment(influenza, 'Rest, fluids, antipyretics, antivirals if within 48 hours or for high risk patients').
treatment(pneumonia, 'Antibiotics (if bacterial), hospitalize if severe, oxygen therapy if needed, chest physiotherapy').
treatment(uti, 'Antibiotics as prescribed, increase fluids, pain relief for dysuria').

% -----------------------------------------------------------
% 5. PREVENTIVE MEASURES
% Preventive actions for each disease
% -----------------------------------------------------------
preventive(covid19, 'Vaccination, mask, hand hygiene, isolation when positive').
preventive(influenza, 'Annual vaccination, hand hygiene, avoid close contact with sick people').
preventive(pneumonia, 'Vaccination (flu, pneumococcal), quit smoking, good hygiene').
preventive(uti, 'Maintain good personal hygiene, stay well hydrated, and avoid holding urine for long periods').

% -----------------------------------------------------------
% 6. SYMPTOM-DISEASE ASSOCIATIONS
% assoc(Disease, Symptom, Weight)
% Weight shows importance of symptom for disease
% -----------------------------------------------------------
% COVID-19
assoc(covid19, fever, 3).
assoc(covid19, cough, 3).
assoc(covid19, sore_throat, 1).
assoc(covid19, shortness_of_breath, 4).
assoc(covid19, fatigue, 2).
assoc(covid19, loss_of_smell, 5).
assoc(covid19, headache, 1).
assoc(covid19, nausea, 1).

% Influenza
assoc(influenza, fever, 4).
assoc(influenza, cough, 3).
assoc(influenza, sore_throat, 2).
assoc(influenza, fatigue, 3).
assoc(influenza, headache, 2).
assoc(influenza, nausea, 1).
assoc(influenza, diarrhea, 1).

% Pneumonia
assoc(pneumonia, fever, 3).
assoc(pneumonia, cough, 4).
assoc(pneumonia, shortness_of_breath, 5).
assoc(pneumonia, chest_pain, 2).
assoc(pneumonia, fatigue, 2).

% Urinary Tract Infection (UTI)
assoc(uti, painful_urination, 5).
assoc(uti, abdominal_pain, 2).
assoc(uti, fever, 2).
assoc(uti, nausea, 1).
assoc(uti, vomiting, 1).

% -----------------------------------------------------------
% 7. HELPER PREDICATES
% Functions to calculate matched symptoms, missing symptoms, confidence
% -----------------------------------------------------------

% matched_weight(Disease, GivenSymptoms, MatchedWeight, MatchedSymptoms)
% Finds total weight of matched symptoms and list of matched symptoms
matched_weight(Disease, Given, MatchedWeight, MatchedSymptoms) :-
    findall(W-S, (assoc(Disease, S, W), member(S, Given)), Pairs),
    findall(W, member(W-_, Pairs), Weights),
    sum_list(Weights, MatchedWeight),
    findall(S, member(_-S, Pairs), MatchedSymptoms).

% total_weight(Disease, Total)
% Total possible weight of all symptoms for a disease
total_weight(Disease, Total) :-
    findall(W, assoc(Disease, _, W), Ws),
    sum_list(Ws, Total).

% missing_important_symptoms(Disease, Given, Missing)
% Returns symptoms not reported by user, ordered high->low importance
missing_important_symptoms(Disease, Given, Missing) :-
    findall(W-S, (assoc(Disease, S, W), \+ member(S, Given)), Pairs),
    sort(0, @>=, Pairs, Sorted),
    findall(S, member(_-S, Sorted), Missing).

% compute_confidence(Disease, Given, Confidence)
% Confidence in percentage based on matched vs total weight
compute_confidence(Disease, Given, Confidence) :-
    matched_weight(Disease, Given, MatchedW, _),
    total_weight(Disease, TotalW),
    (TotalW =:= 0 -> Confidence = 0 ;
     ConfFloat is (MatchedW / TotalW) * 100,
     round(ConfFloat, Confidence)).

% justification(Disease, Given, JustStr)
% Generates justification string explaining diagnosis
justification(Disease, Given, JustStr) :-
    matched_weight(Disease, Given, MatchedW, MatchedSymptoms),
    missing_important_symptoms(Disease, Given, Missing),
    format(string(S1), 'Matched symptoms: ~w (weight sum: ~w).', [MatchedSymptoms, MatchedW]),
    (Missing = [] ->
        S2 = ' No major associated symptoms missing.'
    ;
        format(string(S2), ' Missing associated symptoms (high->low importance): ~w.', [Missing])
    ),
    atomic_list_concat([S1, S2], ' ', JustStr).

% -----------------------------------------------------------
% 8. DIAGNOSIS PREDICATES
% diagnose(+Symptoms, -ResultsSorted)
% Returns list of diagnosis sorted by confidence (dominant) and severity (tie-breaker)
% -----------------------------------------------------------
diagnose(GivenSymptoms, ResultsSorted) :-
    findall(diagnosis(Disease, Severity, Confidence, Treatment, Justification),
            (disease(Disease),
             disease_severity(Disease, Severity),
             compute_confidence(Disease, GivenSymptoms, Confidence),
             Confidence > 0,
             treatment(Disease, Treatment),
             justification(Disease, GivenSymptoms, Justification)
            ),
            Results),
    map_list_to_pairs(score_for_sorting, Results, Pairs),
    keysort(Pairs, SortedPairsAsc),
    reverse(SortedPairsAsc, SortedPairsDesc),
    pairs_values(SortedPairsDesc, ResultsSorted).

% score_for_sorting(+Diagnosis, -Score)
% Corrected: Confidence dominates, severity only tie-breaker
score_for_sorting(diagnosis(_Disease, Severity, Confidence, _, _), Score) :-
    severity_value(Severity, SV),
    Score is Confidence * 100 + SV.  % Confidence dominant

% diagnose(+SymptomsList, -TopDisease, -Recommendation)
% Returns top-most likely disease along with treatment, preventive, justification, confidence
diagnose(SymptomsList, TopDisease, Recommendation) :-
    diagnose(SymptomsList, [diagnosis(TopDisease, Severity, Confidence, Treat, Just)|_]),
    preventive(TopDisease, Prev),
    Recommendation = recommendation{
        treatment: Treat,
        preventive: Prev,
        justification: Just,
        confidence: Confidence,
        severity: Severity
    }.

% -----------------------------------------------------------
% 9. POSSIBLE DISEASES
% Returns all possible diseases with confidence > 0
% -----------------------------------------------------------
possible_diseases(GivenSymptoms, DiseasesList) :-
    findall(Disease-Confidence,
            (disease(Disease),
             compute_confidence(Disease, GivenSymptoms, Confidence),
             Confidence > 0),
            TempList),
    sort(2, @>=, TempList, DiseasesList).

% -----------------------------------------------------------
% 10. TREATMENT & PREVENTIVE QUERIES
% -----------------------------------------------------------
treatment_for(Disease, Treatment) :- treatment(Disease, Treatment).
preventive_for(Disease, Measures) :- preventive(Disease, Measures).

% -----------------------------------------------------------
% 11. PRETTY PRINT RECOMMENDATION
% Print formatted output for top diagnosis
% -----------------------------------------------------------
print_recommendation(Disease, Rec) :-
    format('Disease: ~w~n', [Disease]),
    format('Severity: ~w~n', [Rec.severity]),
    format('Confidence: ~w%%~n', [Rec.confidence]),
    format('Treatment: ~w~n', [Rec.treatment]),
    format('Preventive: ~w~n', [Rec.preventive]),
    format('Justification: ~w~n', [Rec.justification]),
    writeln('----------------------------------').

% -----------------------------------------------------------
% 12. RUN DIAGNOSIS (wrapper for clean output)
% Use this to run diagnosis without extra Prolog dictionary print
% Example: ?- run_diagnosis([fever, cough, loss_of_smell]).
% -----------------------------------------------------------
diagnose(Symptoms) :-
    diagnose(Symptoms, Disease, Rec),
    print_recommendation(Disease, Rec),
    !.  % cut prevents printing variable bindings

% -----------------------------------------------------------
% End of Expert System
% -----------------------------------------------------------
