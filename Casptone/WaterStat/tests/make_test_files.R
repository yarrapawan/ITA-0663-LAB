# STEP 0 - Setup: Create synthetic invalid/edge-case test datasets in tests/data/
# from data/water_quality.csv without modifying any source data.

dir.create("tests/data", recursive = TRUE, showWarnings = FALSE)
dir.create("tests/results", recursive = TRUE, showWarnings = FALSE)

df <- utils::read.csv("data/water_quality.csv", stringsAsFactors = FALSE, check.names = FALSE)

# 1. missing_column.csv (Hardness column removed)
df_missing <- df[, setdiff(names(df), "Hardness"), drop = FALSE]
utils::write.csv(df_missing, "tests/data/missing_column.csv", row.names = FALSE)

# 2. text_in_number.csv (Sulfate converted to character; first 5 values set to "abc")
df_text <- df
df_text$Sulfate <- as.character(df_text$Sulfate)
df_text$Sulfate[1:5] <- "abc"
utils::write.csv(df_text, "tests/data/text_in_number.csv", row.names = FALSE)

# 3. empty.csv (empty file)
file.create("tests/data/empty.csv")
writeLines(character(0), "tests/data/empty.csv")

# 4. one_class.csv (Potability set to 1 for every row)
df_one <- df
df_one$Potability <- 1L
utils::write.csv(df_one, "tests/data/one_class.csv", row.names = FALSE)

cat("Created test files in tests/data/:\n")
for (f in list.files("tests/data", full.names = TRUE)) {
  cat(sprintf("  - %s (%d bytes)\n", f, file.info(f)$size))
}
