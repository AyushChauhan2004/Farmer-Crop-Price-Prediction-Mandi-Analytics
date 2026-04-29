
CREATE DATABASE IF NOT EXISTS mandi_analytics;
USE mandi_analytics;
DROP TABLE IF EXISTS prices;
DROP TABLE IF EXISTS mandis;
DROP TABLE IF EXISTS crops;
DROP TABLE IF EXISTS states;
CREATE TABLE states (
    state_id INT AUTO_INCREMENT PRIMARY KEY,
    state_name VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE crops (
    crop_id INT AUTO_INCREMENT PRIMARY KEY,
    crop_name VARCHAR(100) NOT NULL UNIQUE
);
CREATE TABLE mandis (
    mandi_id INT AUTO_INCREMENT PRIMARY KEY,
    mandi_name VARCHAR(150) NOT NULL,
    district_name VARCHAR(100) NOT NULL,
    state_id INT NOT NULL,

    FOREIGN KEY (state_id)
        REFERENCES states(state_id)
        ON DELETE CASCADE,
    UNIQUE (mandi_name, district_name, state_id)
);
CREATE TABLE prices (
    price_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    price_date DATE NOT NULL,
    mandi_id INT NOT NULL,
    crop_id INT NOT NULL,
    variety VARCHAR(100),
    grade VARCHAR(100),
    min_price DECIMAL(10,2),
    max_price DECIMAL(10,2),
    modal_price DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (mandi_id) REFERENCES mandis(mandi_id),
    FOREIGN KEY (crop_id) REFERENCES crops(crop_id),
    INDEX idx_date (price_date),
    INDEX idx_crop_date (crop_id, price_date),
    INDEX idx_mandi_date (mandi_id, price_date)
);
