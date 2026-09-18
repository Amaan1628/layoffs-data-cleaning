-- Removing Duplicates

select *
from layoffs_staging;

with duplicate_cte as
(
select *,
row_number() over(partition by company,location, industry,percentage_laid_off,stage,funds_raised_millions, total_laid_off, `date`) as row_num
from layoffs_staging
)
select *
from duplicate_cte
where row_num > 1
;

-- Created layoffs_staging2 to delete the rows with roww_num > 1

select *
from layoffs_staging2;


insert into layoffs_staging2
select *,
row_number() over(partition by company,location, industry,percentage_laid_off,stage,funds_raised_millions, total_laid_off, `date`) as roww_num
from layoffs_staging;

delete 
from layoffs_staging2
where roww_num > 1;


select *
from layoffs_staging2
where roww_num > 1;

-- -----------------------------------------------------
-- Standardizing data
select *
from layoffs_staging2
;

-- 1. COMPANY NAME
update layoffs_staging2
set company = trim(company);


-- 2  INDUSTRY & COUNTRY
select *
from layoffs_staging2
where industry like 'crypto%'
;

update layoffs_staging2
set industry = "Crypto"
where industry like 'crypto%'
;

select distinct country
from layoffs_staging2
order by 1
;

update layoffs_staging2
set country = trim(trailing '.'from country)
where country like 'United States%'
;

select distinct country, trim(country)
from layoffs_staging2
where country like 'United%'
;


-- 3. Changing Date type

select `date`, STR_TO_DATE(`date`, '%m/%d/%Y')
from layoffs_staging2
;

update layoffs_staging2
set `date` = STR_TO_DATE(`date`, '%m/%d/%Y')
;

alter table layoffs_staging2
modify column `date` DATE
;

-- NULL & BLANK VALUES  ---------------------------------------

update layoffs_staging2
set industry = null
where industry = '';


select t1.company , t1.industry, t2.company , t2.industry
from layoffs_staging2 t1
join layoffs_staging2 t2
	on t1.company = t2.company
where (t1.industry is null)
and t2.industry is not null
;

update layoffs_staging2 t1
join layoffs_staging2 t2
	on t1.company = t2.company
set t1.industry = t2.industry
where t1.industry is null
and t2.industry is not null
;

-- Delete data which is unecessary ----------------------------

delete
from layoffs_staging2
where total_laid_off is null
and percentage_laid_off is null;

-- DELETING UNNECESSARY COLUMNS  
alter table layoffs_staging2
drop column roww_num;

select *
from layoffs_staging2;









