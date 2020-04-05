--------------------------------------------------
--SQL Data Analysis Exercises – Online Advertising
--------------------------------------------------

--Basic Analysis--

--1
SELECT TOP 10 *
FROM ads a
ORDER BY a.ad_name

--2
SELECT *
FROM clicks
WHERE country = 'Sweden' AND browser = 'Chrome'

--3
SELECT *
FROM conversions
WHERE YEAR(conversion_date) = 2017

--Advanced Analysis--

--1-Using Clicks table, what is the most frequently used browser ?
SELECT TOP 1 browser, COUNT(*) 'cnt'
FROM clicks
GROUP BY browser
ORDER BY cnt DESC

--2-Which ad has the highest amount of clicks ? display the distribution of clicks for each country
SELECT a.ad_name, c.country, COUNT(*) 'num_of_clicks'
FROM ads a JOIN clicks c
	ON c.ad_id = a.ad_id
WHERE a.ad_id = (SELECT TOP 1 ad_id
				 FROM clicks 
				 GROUP BY ad_id
				 ORDER BY COUNT(*) DESC)
GROUP BY a.ad_name, c.country
ORDER BY COUNT(*) DESC

--3-Conversion rate is calculated using the following formula : SUM(total_conversions) \ SUM(total_clicks) * 100. Find out the conversion rate for the ad with the highest amount of clicks
SELECT COUNT(con.conversion_id) 'total_conversion', COUNT(cl.click_id) 'total_clicks',
	   CONCAT(CAST(COUNT(con.conversion_id) AS FLOAT) /CAST(COUNT(cl.click_id)AS FLOAT) * 100, '%') 'conversion_rate'
FROM conversions con RIGHT JOIN clicks cl
	ON cl.click_id = con.click_id
WHERE cl.ad_id = (SELECT TOP 1 ad_id
				 FROM clicks 
				 GROUP BY ad_id
				 ORDER BY COUNT(*) DESC)

--4-Display the top-5 ads, having the highest conversion rate
SELECT TOP 5 ad.ad_id, ad.ad_name,
       CONCAT(CAST(CAST(COUNT(con.conversion_id) AS FLOAT) / CAST(COUNT(cl.click_id) AS FLOAT) * 100 AS NUMERIC (8,2)), '%') 'conv_prec'
FROM conversions con RIGHT JOIN clicks cl
  ON cl.click_id = con.click_id JOIN ads ad
  ON ad.ad_id = cl.ad_id
GROUP BY ad.ad_name, ad.ad_id
ORDER BY CAST(COUNT(con.conversion_id) AS FLOAT) / CAST(COUNT(cl.click_id) AS FLOAT) DESC

--5-Is there any conversion rate differance between the browsers?
SELECT cl.browser,
       CONCAT(CAST(CAST(COUNT(con.conversion_id) AS FLOAT) / CAST(COUNT(cl.click_id) AS FLOAT) * 100 AS NUMERIC (8,2)), '%') 'conv_prec'
FROM conversions con RIGHT JOIN clicks cl
  ON cl.click_id = con.click_id JOIN ads ad
  ON ad.ad_id = cl.ad_id
GROUP BY cl.browser
ORDER BY CAST(COUNT(con.conversion_id) AS FLOAT) / CAST(COUNT(cl.click_id) AS FLOAT) DESC

--6-In average, for each ad, how many days it took for a click to become a conversion?
SELECT ad.ad_name, AVG(DATEDIFF(DD, cl.click_date, con.conversion_date)) 'days_became_conv_avg'
FROM conversions con RIGHT JOIN clicks cl
  ON cl.click_id = con.click_id JOIN ads ad
  ON ad.ad_id = cl.ad_id
GROUP BY ad.ad_name
ORDER BY days_became_conv_avg DESC

--7-What is the most frequently used browser in Brazil
SELECT TOP 1 cl.browser, COUNT(cl.click_id)
FROM clicks cl
WHERE country = 'Brazil'
GROUP BY cl.browser
ORDER BY COUNT(cl.click_id) DESC