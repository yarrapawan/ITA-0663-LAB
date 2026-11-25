| Specification | Required Value | Achieved Value | Status |
|---|---|---|---|
| Manual formula vs R function (F, χ², t, r, ρ) | Match to 4 decimals | Matched in all five test scripts | Pass |
| Validation messages | Clear message for each invalid file; modeling blocked | missing_column flagged Hardness as missing; text_in_number gave a non-numeric warning; one_class disabled modeling; empty.csv: Pass (read_error='The file is empty.'; ok_model=FALSE) | Pass |
| Reproducibility with the same seed | Identical results | Seed 42 repeated gave identical AUC (0.4901), coefficients and counts (TP 0, TN 400, FP 0, FN 256); seed 7 gave a different AUC (0.5116) | Pass |
| Threshold update | All metrics change with the slider | Predicted-potable samples fell from 656 (thresholds 0.1–0.3) to 237 (0.4) to 0 (0.5–0.9); accuracy rose from 0.3902 to 0.6098 | Pass |
| Invalid input handling | No crash; clear message | No trained model, empty inputs, negative value and pH above 14 each gave a clear message; Solids = 999,999 returned a prediction (prob=0.4732) with an unusual-value flag (outside=Solids); no dataset loaded gave a friendly message | Pass |
