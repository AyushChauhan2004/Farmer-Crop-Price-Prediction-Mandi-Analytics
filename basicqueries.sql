USE clean_mandi_analytics;

-- 1. Average modal price per crop.
SELECT
    c.crop_name,
    ROUND(AVG(p.modal_price), 2) AS avg_modal_price,
    COUNT(*) AS observations
FROM prices p
JOIN crops c
    ON c.crop_id = p.crop_id
GROUP BY c.crop_name
ORDER BY avg_modal_price DESC;

-- 2. Top 5 most expensive crops by average modal price.
SELECT
    c.crop_name,
    ROUND(AVG(p.modal_price), 2) AS avg_modal_price
FROM prices p
JOIN crops c
    ON c.crop_id = p.crop_id
GROUP BY c.crop_name
ORDER BY avg_modal_price DESC
LIMIT 5;

-- 3. State-wise price range and volatility proxy.
SELECT
    s.state_name,
    ROUND(MIN(p.modal_price), 2) AS min_modal_price,
    ROUND(MAX(p.modal_price), 2) AS max_modal_price,
    ROUND(MAX(p.modal_price) - MIN(p.modal_price), 2) AS price_range,
    ROUND(STDDEV_POP(p.modal_price), 2) AS modal_price_stddev,
    COUNT(*) AS observations
FROM prices p
JOIN mandis m
    ON m.mandi_id = p.mandi_id
JOIN states s
    ON s.state_id = m.state_id
GROUP BY s.state_name
ORDER BY price_range DESC;

-- 4. Average crop price by state.
SELECT
    s.state_name,
    c.crop_name,
    ROUND(AVG(p.modal_price), 2) AS avg_modal_price,
    COUNT(*) AS observations
FROM prices p
JOIN mandis m
    ON m.mandi_id = p.mandi_id
JOIN states s
    ON s.state_id = m.state_id
JOIN crops c
    ON c.crop_id = p.crop_id
GROUP BY s.state_name, c.crop_name
ORDER BY s.state_name, avg_modal_price DESC;

-- 5. Monthly trend by crop.
SELECT
    c.crop_name,
    DATE_FORMAT(p.price_date, '%Y-%m') AS price_month,
    ROUND(AVG(p.modal_price), 2) AS avg_modal_price,
    COUNT(*) AS observations
FROM prices p
JOIN crops c
    ON c.crop_id = p.crop_id
GROUP BY c.crop_name, DATE_FORMAT(p.price_date, '%Y-%m')
ORDER BY c.crop_name, price_month;
