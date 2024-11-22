use bank_data;  

select CustomerId  from customerinfo   # Q2 objective ANS  
where quarter(Bank_DOJ) = 4 
order by EstimatedSalary desc 
limit 5 ; 

select avg(NumOfProducts)  from bank_churn  #Q3 objective ANS 
where HasCreditCard =  1;  

SELECT AVG(CASE WHEN Exited = 1 THEN CreditScore END) AS AverageCreditScoreExited,       -- Q5 objective ans
AVG(CASE WHEN Exited = 0 THEN CreditScore END) AS AverageCreditScoreremain
FROM bank_churn;
    
SELECT c.GenderID, g.GenderCategory, AVG(c.EstimatedSalary) AS AverageEstimatedSalary,   -- Q6 objective ans 
SUM(CASE WHEN bc.IsActiveMember = 1 THEN 1 ELSE 0 END) AS ActiveAccounts
FROM bank_churn bc
JOIN customerinfo c ON bc.CustomerId = c.CustomerId 
JOIN gender g on c.GenderID = g.GenderID
GROUP BY g.GenderID , g.GenderCategory;



WITH CreditScoreSegments AS        -- Q7 objective ANS 
( SELECT Exited, 
CASE WHEN CreditScore < 500 THEN 'Low'
WHEN CreditScore >= 500 AND CreditScore < 700 THEN 'Medium'
WHEN CreditScore >= 700 THEN 'High'
ELSE 'Unknown'
END AS CreditScoreSegment
FROM bank_churn
)
SELECT CreditScoreSegment,
COUNT(*) AS TotalCustomers,
SUM(Exited) AS ExitedCustomers,
Round((SUM(Exited)) / COUNT(*) * 100,2) AS ExitRate
FROM CreditScoreSegments
GROUP BY CreditScoreSegment
ORDER BY ExitRate desc
LIMIT 1; 

SELECT  g.GeographyID , g.GeographyLocation ,  COUNT(bc.CustomerId) AS CUSTOMER_COUNT     -- Q8 OBJECTIVE ANS 
FROM bank_churn bc
JOIN customerinfo c ON bc.CustomerId = c.CustomerId 
JOIN geography g ON c.GeographyID = g.GeographyID
WHERE bc.IsActiveMember = 1 AND bc.Tenure > 5 
GROUP BY g.GeographyID , g.GeographyLocation 
ORDER BY CUSTOMER_COUNT DESC ; 

-- Q11 OBJECTIVE ANS 
SELECT EXTRACT(YEAR FROM Bank_DOJ) AS JoiningYEAR, 
COUNT(*) AS Customer_count 
FROM customerinfo
GROUP BY  JoiningYEAR 
ORDER BY  JoiningYEAR DESC ;


-- Q15 objective ans 
SELECT ci.GeographyID, geo.GeographyLocation, g.GenderCategory AS Gender,
AVG(ci.EstimatedSalary) AS AverageIncome,
RANK() OVER (PARTITION BY g.GenderID ORDER BY AVG(ci.EstimatedSalary) DESC) AS GenderRank
FROM customerinfo ci
JOIN gender g ON ci.GenderID = g.GenderID
JOIN geography geo ON ci.GeographyID = geo.GeographyID
GROUP BY ci.GeographyID, g.GenderCategory, g.GenderID, geo.GeographyLocation
ORDER BY ci.GeographyID, GenderRank;

-- Q16 objective ANS 
SELECT CASE
WHEN ci.Age BETWEEN 18 AND 30 THEN '18 TO 30'
WHEN ci.Age BETWEEN 31 AND 50 THEN '31 TO 50'
WHEN ci.Age > 50 THEN '50 ABOVE'
END AS AgeBracket,
AVG(bc.Tenure) AS AverageTenure
FROM bank_churn bc
JOIN customerinfo ci ON bc.CustomerId = ci.CustomerId
WHERE bc.Exited = 1 
GROUP BY AgeBracket
ORDER BY AgeBracket;

-- Q19 objective ans 
WITH ChurnedCustomers AS (
SELECT CreditScore,
CASE WHEN CreditScore BETWEEN 0 AND 300 THEN '0-300'
WHEN CreditScore BETWEEN 301 AND 500 THEN '301-500'
WHEN CreditScore BETWEEN 501 AND 700 THEN '501-700'
WHEN CreditScore BETWEEN 701 AND 850 THEN '701-850'
ELSE 'Unknown'
END AS CreditScoreBucket
FROM bank_churn
WHERE Exited = 1 
)
SELECT CreditScoreBucket, COUNT(*) AS NumberOfCustomersChurned,
RANK() OVER (ORDER BY COUNT(*) DESC) AS CreditScoreRank
FROM ChurnedCustomers
GROUP BY CreditScoreBucket
ORDER BY CreditScoreRank;

SELECT bc.*,       -- Q23 objective ans
(SELECT ec.ExitCategory FROM exitcustomer ec WHERE ec.ExitID = bc.Exited) AS ExitCategory
FROM bank_churn bc;    



SELECT c.CustomerId, c.Surname, b.IsActiveMember   -- Q25 objective ANS 
FROM customerinfo c
JOIN bank_churn b ON b.CustomerId = c.CustomerId
WHERE Surname LIKE '%on';

-- Q9 subjective question 
SELECT c.GeographyID , g.GeographyLocation, count(c.CustomerId) as number_of_customers ,
count(case when b.IsActiveMember = 1 then 1 end ) as active_count
FROM customerinfo c
INNER JOIN bank_churn b ON c.CustomerId = b.CustomerId
INNER JOIN geography g ON  c.GeographyID = g.GeographyID
group by c.GeographyID, g.GeographyLocation ; 


