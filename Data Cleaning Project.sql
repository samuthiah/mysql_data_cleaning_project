-- 1. Remove Duplicates
-- 2. Standardize the Data
-- 3. Null Values or blank values
-- 4. Remove Any Columns

CREATE TABLE layoffs_staging
LIKE layoffs;

INSERT INTO layoffs_staging
SELECT *
FROM layoffs;

SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, industry, total_laid_off, percentage_laid_off, `date`) as row_num
FROM layoffs_staging;

WITH duplicate_cte AS
(
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) as row_num
FROM layoffs_staging
)
SELECT *
FROM duplicate_cte 
WHERE row_num > 1;

CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` text,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` text,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


INSERT INTO layoffs_staging2
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) as row_num
FROM layoffs_staging;

DELETE
FROM layoffs_staging2
WHERE row_num > 1;

UPDATE layoffs_staging2
SET company = TRIM(company);

UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

UPDATE layoffs_staging2
SET country = 'United States'
WHERE country LIKE 'United States%';

UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;

UPDATE layoffs_staging2
SET industry = NULL
WHERE industry = '';

UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL; 

ALTER TABLE layoffs_staging2
DROP COLUMN row_num;
