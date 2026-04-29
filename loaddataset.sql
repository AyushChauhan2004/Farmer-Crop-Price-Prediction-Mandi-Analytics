CREATE TEMPORARY TABLE staging_data (
    date VARCHAR(50),
    state VARCHAR(100),
    district VARCHAR(100),
    market VARCHAR(150),
    crop VARCHAR(100),
    variety VARCHAR(100),
    grade VARCHAR(100),
    min_price VARCHAR(50),
    max_price VARCHAR(50),
    modal_price VARCHAR(50)
);
LOAD DATA INFILE 'C:/Users/Grit/Documents/Codex/India Crop Price Dataset.csv'
INTO TABLE staging_data
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(date, state, district, market, crop, variety, grade, min_price, max_price, modal_price);

INSERT IGNORE INTO states (state_name)
SELECT DISTINCT TRIM(state)
FROM staging_data
WHERE state IS NOT NULL;

INSERT IGNORE INTO crops (crop_name)
SELECT DISTINCT TRIM(crop)
FROM staging_data
WHERE crop IS NOT NULL;

INSERT IGNORE INTO mandis (mandi_name, district_name, state_id)
SELECT DISTINCT
    TRIM(s.market),
    TRIM(s.district),
    st.state_id
FROM staging_data s
JOIN states st 
    ON TRIM(s.state) = st.state_name
WHERE s.market IS NOT NULL;

INSERT INTO prices (
    price_date,
    mandi_id,
    crop_id,
    variety,
    grade,
    min_price,
    max_price,
    modal_price
)
SELECT
    STR_TO_DATE(s.date, '%Y-%m-%d'),
    
    m.mandi_id,
    c.crop_id,
    
    TRIM(s.variety),
    TRIM(s.grade),

    CAST(NULLIF(s.min_price, '') AS DECIMAL(10,2)),
    CAST(NULLIF(s.max_price, '') AS DECIMAL(10,2)),
    CAST(NULLIF(s.modal_price, '') AS DECIMAL(10,2))

FROM staging_data s
JOIN states st 
    ON TRIM(s.state) = st.state_name
JOIN mandis m 
    ON TRIM(s.market) = m.mandi_name
    AND TRIM(s.district) = m.district_name
    AND m.state_id = st.state_id
JOIN crops c 
    ON TRIM(s.crop) = c.crop_name;
