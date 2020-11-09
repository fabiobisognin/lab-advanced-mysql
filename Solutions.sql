SELECT titleauthor.title_ID, titleauthor.au_id, 
(titles.price * sales.qty * titles.royalty / 100 * titleauthor.royaltyper / 100) "sales_royalty"
FROM titleauthor 
JOIN titles 
ON titles.title_id = titleauthor.title_id
JOIN sales
ON sales.title_id = titleauthor.title_id
ORDER BY titleauthor.title_id;

SELECT ro.title_ID, ro.au_id, SUM(sales_royalty) "All Royalties"
FROM (
SELECT titleauthor.title_ID, titleauthor.au_id, 
(titles.price * sales.qty * titles.royalty / 100 * titleauthor.royaltyper / 100) "sales_royalty"
FROM titleauthor 
JOIN titles 
ON titles.title_id = titleauthor.title_id
JOIN sales
ON sales.title_id = titleauthor.title_id) as ro
group by ro.au_id, ro.title_id;

SELECT AuthorID, SUM(titles.advance*(titleauthor.royaltyper/100)+Royalties) AS Profit
FROM (SELECT TitleID, AuthorID, 
        SUM(Royalty) AS Royalties
        FROM (SELECT titles.title_id AS TitleID, titleauthor.au_id AS AuthorID, 
                titles.price*sales.qty*(titles.royalty/100)*(titleauthor.royaltyper/100) AS Royalty
                FROM titleauthor 
                JOIN titles ON titles.title_id=titleauthor.title_id
                JOIN sales ON titles.title_id=sales.title_id) AS royalties
        GROUP BY royalties.TitleID, royalties.AuthorID) AS royal_au_tit
        JOIN titles ON royal_au_tit.TitleID=titles.title_id
JOIN titleauthor ON titles.title_id=titleauthor.title_id AND AuthorID=titleauthor.au_id
GROUP BY AuthorID
ORDER BY Profit DESC

LIMIT 3;

CREATE TEMPORARY TABLE temp_royalty_table
SELECT titleauthor.au_id, titleauthor.title_ID,  
(titles.price * sales.qty * titles.royalty / 100 * titleauthor.royaltyper / 100) "sales_royalty"
FROM titleauthor 
JOIN titles 
ON titles.title_id = titleauthor.title_id
JOIN sales
ON sales.title_id = titleauthor.title_id;
DROP TABLE tabla2;
CREATE TEMPORARY TABLE tabla2
SELECT ro.title_ID, ro.au_id, SUM(sales_royalty) "All_Royalties"
FROM temp_royalty_table AS ro
group by ro.au_id, ro.title_id;
SELECT * FROM tabla2;
SELECT *,royal_au_tit.au_id, SUM(titles.advance*(titleauthor.royaltyper/100)+"All Royalties") AS Profit
FROM tabla2 AS royal_au_tit
        JOIN titles ON royal_au_tit.title_ID=titles.title_id
JOIN titleauthor ON titles.title_id=titleauthor.title_id AND royal_au_tit.au_id=titleauthor.au_id
GROUP BY royal_au_tit.au_id
ORDER BY Profit DESC
LIMIT 3;

CREATE TEMPORARY TABLE most_profiting_authors
SELECT royal_au_tit.au_id, SUM(titles.advance*(titleauthor.royaltyper/100))+All_Royalties AS Profit
FROM tabla2 AS royal_au_tit
        JOIN titles ON royal_au_tit.title_ID=titles.title_id
JOIN titleauthor ON titles.title_id=titleauthor.title_id AND royal_au_tit.au_id=titleauthor.au_id
GROUP BY royal_au_tit.au_id
ORDER BY Profit DESC;
select * from most_profiting_authors