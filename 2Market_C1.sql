-- Create the tables
-- 1st table: marketing data

create table marketing_data_cleaned (
ID integer primary key,
Year_Birth integer,
Age integer,
Marital_Status varchar(50),
Income integer,
Kidhome integer,
Teenhome integer,
Sum_Kid_Teen integer,
Recency integer,
AmtLiq integer,
AmtVege integer,
AmtMeat integer,
AmtFish integer,
AmtChocolates integer,
AmtComm integer,
Sum_Purchases integer,
NumDeals integer,
NumWebBuy integer,
NumWalkinPur integer,
NumVisits integer,
Response boolean,
Complain boolean,
Country varchar(50),
Count_Success integer);

-- 2nd table: ad data
create table ad_data_cleaned (
ID integer primary key,
Bulkmail_ad boolean,
Twitter_ad boolean,
Instagram_ad boolean,
Facebook_ad boolean,
Brochure_ad boolean);


-- Update country names
update "marketing_data_cleaned"
set "country" = replace("country", 'AUS', 'Australia');

update "marketing_data_cleaned"
set "country" = replace("country", 'CA', 'Canada');

update "marketing_data_cleaned"
set "country" = replace("country", 'GER', 'Germany');

update "marketing_data_cleaned"
set "country" = replace("country", 'IND', 'India');

update "marketing_data_cleaned"
set "country" = replace("country", 'ME', 'Montenegro');

update "marketing_data_cleaned"
set "country" = replace("country", 'SA', 'South Africa');

update "marketing_data_cleaned"
set "country" = replace("country", 'SP', 'Spain');

update "marketing_data_cleaned"
set "country" = replace("country", 'US', 'USA');

-- How much does each country spend?

select "country",
country_spend,
to_char(country_spend*100/sum(country_spend) over(), 'fm00D00') as percent
from (
	select "country",
	sum("sum_purchases") as country_spend
	from public."marketing_data_cleaned"
	group by "country"
	order by country_spend desc
	) as c;

-- How much does each country spend on each product?

select "country", 
sum("amtliq") as liq, 
sum("amtvege") as veg, 
sum("amtmeat") as meat,
sum("amtfish") as fish,
sum("amtchocolates") as choc,
sum("amtcomm") as comm
from public."marketing_data_cleaned"
group by "country"
order by sum("sum_purchases") desc;

-- Which products are the most popular based on marital status?
-- Remove #N/A from marketing data table

delete from "marketing_data_cleaned" 
where "marital_status" = '#N/A';

select "marital_status", 
sum("amtliq") as liq, 
sum("amtvege") as veg, 
sum("amtmeat") as meat,
sum("amtfish") as fish,
sum("amtchocolates") as choc,
sum("amtcomm") as comm
from public."marketing_data_cleaned"
group by "marital_status"
order by sum("sum_purchases") desc;

-- Which products are the most popular depending on how many kids are at home?

select "sum_kid_teen",
sum("amtliq") as liq, 
sum("amtvege") as veg, 
sum("amtmeat") as meat,
sum("amtfish") as fish,
sum("amtchocolates") as choc,
sum("amtcomm") as comm
from public."marketing_data_cleaned"
group by "sum_kid_teen"
order by sum("sum_purchases") desc;

-- Social media sense check

select "country",
conversion,
sum(bulkmail + twitter + instagram + facebook + brochure),
bulkmail,
twitter,
instagram,
facebook,
brochure
from (
	select mar."country",
	sum(mar."sum_purchases") as country_spend,
	sum((mar."count_success")::int) as conversion,
	sum((ad."bulkmail_ad")::int) as bulkmail,
	sum((ad."twitter_ad")::int) as twitter,
	sum((ad."instagram_ad")::int) as instagram,
	sum((ad."facebook_ad")::int) as facebook,
	sum((ad."brochure_ad")::int) as brochure
	from public."marketing_data_cleaned" mar
	inner join public."ad_data_cleaned" ad using ("id")
	group by mar."country"
	) as a
group by a."country", 
a.conversion, 
a.bulkmail, 
a.twitter, 
a.instagram, 
a.facebook, 
a.brochure,
a.country_spend
order by country_spend desc;

-- Which social media platform is the most effective per country?

select "country",
twitter,
instagram,
facebook
from (
	select mar."country",
	sum(mar."sum_purchases") as country_spend,
	sum((ad."twitter_ad")::int) as twitter,
	sum((ad."instagram_ad")::int) as instagram,
	sum((ad."facebook_ad")::int) as facebook
	from public."marketing_data_cleaned" mar
	inner join public."ad_data_cleaned" ad using ("id")
	group by mar."country") as a
	order by country_spend desc;

-- Which social media platforms are associated with the highest sales per country?

select mar."country",
sum(mar."sum_purchases") as country_spend,
sum((ad."twitter_ad")::int) as twitter,
sum((ad."instagram_ad")::int) as instagram,
sum((ad."facebook_ad")::int) as facebook
from public."marketing_data_cleaned" mar
left join public."ad_data_cleaned" ad using ("id")
group by mar."country"
order by country_spend desc;

-- Which marketing channel is the most effective based on marital status?

select mar."marital_status",
sum((ad."twitter_ad")::int) as twitter,
sum((ad."instagram_ad")::int) as instagram,
sum((ad."facebook_ad")::int) as facebook
from public."marketing_data_cleaned" mar
left join public."ad_data_cleaned" ad using ("id")
group by mar."marital_status";
