-- 创建示例表并插入数据
CREATE TABLE products (
    id INT AUTO_INCREMENT PRIMARY KEY,
    product_data VARCHAR(255)
);


CREATE TEMPORARY TABLE profit.numbers (n INT);
INSERT INTO profit.numbers (n) VALUES (1), (2), (3), (4), (5), (6), (7), (8), (9), (10);


SELECT
    序号,
    TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(SUBSTRING(货物, LOCATE('(', 货物)), ',', numbers.n), ',', -1)) AS product_part,
    CAST(
        REGEXP_REPLACE(
            REGEXP_SUBSTR(
                TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(SUBSTRING(货物, LOCATE('(', 货物)), ',', numbers.n), ',', -1)),
                '\\(([0-9]+)\\)'
            ),
            '[^0-9]',
            ''
        ) AS UNSIGNED
    ) AS quantity
FROM
    profit.人工导入陈老师测试
JOIN
    profit.numbers
    ON CHAR_LENGTH(SUBSTRING(货物, LOCATE('(', 货物))) - CHAR_LENGTH(REPLACE(SUBSTRING(货物, LOCATE('(', 货物)), ',', '')) >= numbers.n - 1
WHERE
    REGEXP_LIKE(货物, '^\\*[\\u4e00-\\u9fa5]+\\*\\(')
ORDER BY
    序号, numbers.n;