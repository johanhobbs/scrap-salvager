-- Drops a database with the same name if it exists.
-- This prevents issues caused by any previous iteration
-- of the same database still existing.
DROP DATABASE IF EXISTS scrap_salvager;

-- Creates the new Database
CREATE DATABASE scrap_salvager;

USE scrap_salvager;

-- Creates a user for the game client

DROP USER IF EXISTS 'scrap_game'@'localhost';

CREATE USER 'scrap_game'@'localhost'
IDENTIFIED BY "thispassword";

-- Sets permissions
-- TODO: Edit permissions so that the game account only has the permissions granted to it

GRANT ALL ON scrap_salvager.* TO 'scrap_game'@'localhost';

-- Sets up tables, starting with those that do not need to
-- reference any foreign keys.
CREATE TABLE `Account` (
accountID INTEGER(10) PRIMARY KEY AUTO_INCREMENT,
username VARCHAR(50) UNIQUE NOT NULL,
`password` VARCHAR(50) NOT NULL,
emailAddress VARCHAR(255) UNIQUE NOT NULL,
failedLoginAttempts INTEGER(10),
accountStatus VARCHAR(15),
suspensionStartTime TIMESTAMP
);

CREATE TABLE `Item_Category` (
itemCategoryID INTEGER(10) PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR(50) UNIQUE NOT NULL
);

CREATE TABLE Tile (
tileID INTEGER(10) PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR(50) UNIQUE NOT NULL,
passibility VARCHAR(10) NOT NULL,
image VARCHAR(28) NOT NULL
);

CREATE TABLE NPC_Behaviour (
behaviourID INTEGER(10) PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR(20)
);

CREATE TABLE Chat (
chatID INTEGER(10) PRIMARY KEY AUTO_INCREMENT
);

-- Now adding tables that do include foreign keys.

CREATE TABLE Map_Type (
mapTypeID INTEGER(10) PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR(20) UNIQUE NOT NULL,
tileID INTEGER(10), -- The default tile that this map will use if no tile is specified
background VARCHAR(28) NOT NULL,
hasGrid BOOLEAN NOT NULL,
CONSTRAINT FK_MapTypeDefaultTile FOREIGN KEY (tileID)
REFERENCES Tile(tileID)
);

CREATE TABLE Map (
mapID INTEGER(10) PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR(60),
mapTypeID INTEGER(10) NOT NULL,
height TINYINT(3) NOT NULL,
width TINYINT(3) NOT NULL,
chatID INTEGER(10) UNIQUE NOT NULL,
CONSTRAINT FK_MapMapType FOREIGN KEY (mapTypeID)
REFERENCES Map_Type(mapTypeID)
);

CREATE TABLE Tile_Map (
mapID INTEGER(10),
xCoordinate TINYINT(3),
yCoordinate TINYINT(3),
tileID INTEGER NOT NULL,
CONSTRAINT FK_TileMapMap FOREIGN KEY (mapID)
REFERENCES Map(mapID),
CONSTRAINT FK_TileMapTile FOREIGN KEY (tileID)
REFERENCES Tile(tileID),
PRIMARY KEY (mapID, xCoordinate, yCoordinate)
);

CREATE TABLE `Character` (
characterID INTEGER(10) PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR(30) UNIQUE NOT NULL,
mapID INTEGER(10) NOT NULL,
`status` BOOLEAN NOT NULL,
currency INTEGER(10),
xPosition TINYINT(3),
yPosition TINYINT(3),
sprite VARCHAR(28),
CONSTRAINT FK_CharacterMap FOREIGN KEY (mapID)
REFERENCES Map(mapID)
);

CREATE TABLE Item (
itemID INTEGER(10) PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR(60) UNIQUE NOT NULL,
itemCategoryID INTEGER(10) NOT NULL,
`value` DECIMAL(7,2),
icon VARCHAR(28),
CONSTRAINT fk_ItemItemCategory FOREIGN KEY (itemCategoryID)
REFERENCES Item_Category(itemCategoryID)
);

CREATE TABLE Item_Map (
mapID INTEGER(10),
xCoordinate TINYINT(3),
yCoordinate TINYINT(3),
itemID INTEGER(10) NOT NULL,
CONSTRAINT fk_ItemMapItem FOREIGN KEY (itemID)
REFERENCES Item(itemID),
PRIMARY KEY (mapID, xCoordinate, yCoordinate)
);

CREATE TABLE Character_Item (
characterID INTEGER(10),
itemID INTEGER(10),
quantity TINYINT(3),
CONSTRAINT fk_CharacterItemCharacter FOREIGN KEY (characterID)
REFERENCES `Character`(characterID),
CONSTRAINT fk_CharacterItemItem FOREIGN KEY (itemID)
REFERENCES Item(itemID),
PRIMARY KEY (characterID, itemID)
);

CREATE TABLE Recipe (
itemCraftedID INTEGER(10),
ingredientID INTEGER(10),
quantity TINYINT(3),
CONSTRAINT fk_RecipeItemCrafted FOREIGN KEY (itemCraftedID)
REFERENCES Item(itemID),
CONSTRAINT fk_RecipeIngredient FOREIGN KEY (ingredientID)
REFERENCES Item(itemID),
PRIMARY KEY (itemCraftedID, ingredientID)
);

CREATE TABLE Player_Character (
characterID INTEGER(10),
accountID INTEGER(10) NOT NULL,
CONSTRAINT fk_PlayerCharacterAccount FOREIGN KEY (accountID)
REFERENCES `Account`(accountID),
CONSTRAINT fk_PlayerCharacterCharacter FOREIGN KEY (characterID)
REFERENCES `Character`(characterID),
PRIMARY KEY (characterID)
);

CREATE TABLE NPC (
characterID INTEGER(10),
behaviourID INTEGER(10) NOT NULL,
CONSTRAINT fk_NPCCharacter FOREIGN KEY (characterID)
REFERENCES `Character`(characterID),
CONSTRAINT fk_NPCNPCBehavior FOREIGN KEY (behaviourID)
REFERENCES NPC_Behaviour(behaviourID),
PRIMARY KEY (characterID)
);

CREATE TABLE Message(
messageID INTEGER(10) PRIMARY KEY AUTO_INCREMENT,
accountID INTEGER(10) NOT NULL,
chatID INTEGER(10) NOT NULL,
`timestamp` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
contents VARCHAR(255) NOT NULL,
CONSTRAINT fk_MessageAccount FOREIGN KEY (accountID)
REFERENCES `Account`(accountID),
CONSTRAINT fk_MessageChat FOREIGN KEY (chatID)
REFERENCES Chat(chatID)
);

CREATE TABLE Account_Chat(
accountID INTEGER(10),
chatID INTEGER(10),
CONSTRAINT fk_AccountChatAccount FOREIGN KEY (accountID)
REFERENCES `Account`(accountID),
CONSTRAINT fk_AccountChatChat FOREIGN KEY (chatID)
REFERENCES Chat(chatID)
);

CREATE TABLE Item_Valuation(
behaviourID INTEGER(10),
itemCategoryID INTEGER(10),
perceivedValueModifier DECIMAL(5,2),
itemSaleModifier DECIMAL(5,2),
CONSTRAINT fk_ItemValuationBehaviour FOREIGN KEY (behaviourID)
REFERENCES NPC_Behaviour(behaviourID),
CONSTRAINT fk_ItemValuationItemCategory FOREIGN KEY (itemCategoryID)
REFERENCES Item_Category(itemCategoryID)
);

CREATE TABLE Player_NPC(
npcID INTEGER(10),
playerID INTEGER(10),
amicability TINYINT(3),
CONSTRAINT fk_PlayerNPCNPC FOREIGN KEY (npcID)
REFERENCES NPC(characterID),
CONSTRAINT fk_PlayerNPCPlayerCharacter FOREIGN KEY (PlayerID)
REFERENCES Player_Character(characterID),
PRIMARY KEY (playerID, npcID)
);

-- Inserts mock Data into the Account table

INSERT INTO `Account` (username, `password`, emailAddress)
VALUES ('gamerguy2000', 'notarealpassword', 'gamerguy2000@gmail.com'),
       ('doeswhateveraspidercan', 'withgreatpower', 'p.parker@gmail.com'),
       ('dougdoug', 'asdfgasdf', 'dougdoug@hotmail.com'),
       ('some_username', 'somepassword7', 'generic_email_address@outlook.com');

-- Select query for debugging

SELECT * FROM `Account`;

-- Inserts mock data into Item_Category table

INSERT INTO `Item_Category` (`name`)
VALUES ("Luxury Goods"), ("Machine Parts"), ("Food"),
       ("Metal/Ore"), ("Wood/Timber"), ("Hide/Leather"),
       ("Survival Supplies"), ("Scrap"), ("Tools"),
       ("Machines");

-- Select query for debugging

SELECT * FROM `Item_Category`;

-- Inserts mock data to the Tile table

INSERT INTO Tile (`name`, passibility, image)
VALUES ("grass", "normal", "grass.png"), ("savannah", "normal", "savannah.png"), ("ice", "slippery", "ice.png"), ("cave floor", "normal", "cave_floor.png"),
	   ("wall", "impassible", "wall.png"), ("tar pit", "slow", "tar_pit.png"), ("sand", "normal", "sand.png"), ("barrier", "impassible", "barrier.png"), ("snow", "normal", "snow.png"),
       ("quicksand", "slow", "quicksand.png"), ("crevasse", "jump only", "crevasse.png"), ("water", "jump only", "water.png");

-- Select query to confirm the values inserted into tile

SELECT * FROM Tile;

-- Inserts mock data into NPC_Behaviour table

INSERT INTO NPC_Behaviour (`name`)
VALUES ("hungry"), ("merchant"), ("helper"), ("chef"), ("lumberjack"), ("forager"), ("salvager"), ("hunter"), ("avaricious");

-- select query to confirm the mock data inserted in the NPC_Behaviour table

SELECT * FROM NPC_Behaviour;

-- Inserts mock data into the Chat table

-- The only column in the chat table is an auto-incrementing primary key, so I can create chats just by tossing empty parens at the table?
-- I still cannot believe that this works. This is very silly.

-- Nonetheless, it is neccessary for the chats table to be populated, otherwise when I populate later tables,
-- any columns that reference this table as foreign keys will break.

INSERT INTO Chat () VALUES (), (), (), (), (), (), (), (), (), (), (), (), (), (), (), (), (), (), (), ();

-- Select query to confirm values were inserted correctly

SELECT * FROM Chat;

-- Inserts mock data into Map_Type table

INSERT INTO Map_Type (`name`, tileID, background, hasGrid)
VALUES	("Field", 1, "field.png", TRUE), ("Desert", 7, "desert.png", TRUE), ("Tundra", 9, "tundra.png", TRUE), ("Mountain", 9, "mountain.png", TRUE),
		("Cave", 4, "cave.png", TRUE), ("City", NULL, "city.png", FALSE), ("Wilderness", 2, "wilderness.png", TRUE);

-- Select query to confirm that mock data was inserted correctly

SELECT * FROM Map_Type;

-- Inserts mock values into Map table

INSERT INTO Map (`name`, mapTypeID, height, width, chatID)
VALUES	("Sunnyfield City", 6, 0, 0, 1), ("Outer Sunnyfield", 1, 25, 25, 2), ("Sand Dune Crossing", 2, 30, 15, 3),
		("Winterstorm Plain", 3, 30, 30, 4), ("Mount Winterstorm", 4, 20, 35, 5), ("No Man's Labyrinth", 5, 30, 35, 6),
        ("The Greater Wilderness", 7, 30, 30, 7), ("Sapphire Blue Oasis", 2, 10, 15, 8), ("Royal Gardens", 1, 10, 10, 9);

-- Select Query to confirm that the data was inserted into Map table correctly. Join query to display the Map Type and the default tile type.

SELECT Map.`name` AS "Map", Map_Type.`name` AS "Type", Map.height, Map.width, Tile.`name` AS "Default tile" FROM Map
JOIN Map_Type ON Map_Type.mapTypeID = Map.mapTypeID
LEFT JOIN Tile ON Tile.tileID = Map_Type.tileID
ORDER BY Map.MapID ASC;

-- Inserts mock data into the Tile_Map table - realistically, there would be more special tiles per map but this is just to show that it can be done really.

INSERT INTO Tile_Map (mapID, xCoordinate, yCoordinate, tileID)
VALUES (2, 5, 5, 12), (2, 6, 5, 12), (2, 5, 6, 12), (2, 6, 6, 12), (3, 10, 10, 6), (4, 5, 5, 3), (4, 5, 25, 3), (4, 5, 26, 3);

-- Selects statement to confirm that the map data has been added. Join statement for human readability.

SELECT Map.`name` AS "Map", Tile_Map.xCoordinate AS "x", Tile_Map.yCoordinate AS "y", Tile.`name` AS "Tile"
FROM Tile_Map
JOIN Map ON Map.mapID = Tile_Map.mapID
JOIN Tile ON Tile.tileID = Tile_Map.tileID
ORDER BY Tile_Map.mapID ASC;

-- Inserts mock data into Character table
-- TODO: Replace this statement with something more robust.
-- As complete knowledge of a character needs to reference both the Character table AND either the NPC or Player table,
-- they should be created at a same time, possibly using common parameters and a procedure.

INSERT INTO `Character` (`name`, mapID, `status`, currency, xPosition, yPosition, sprite)
VALUES	("Tuto", 2, TRUE, 10000000, 12, 12, "tuto.png"), ("Amity", 3, TRUE, 50000, 5, 10, "amity.png"),
		("Spidey", 1, FALSE, 12, 0, 0, "player-a2.png"), ("Finch", 6, TRUE, 15000, 28, 20, "player-b3.png"),
        ("Dandelion", 2, FALSE, 150, 12, 13, "player-a2.png"), ("Jackyll", TRUE, 7, 9576432, 10, 25, "player-a1.png"),
        ("Wani", 3, FALSE, 1324, 10, 25, "npc-merchant.png");

-- Select statement to check the mock data has been added successfully

SELECT * FROM `Character`;

-- Populates the item table with mock data

INSERT INTO Item	(`name`, itemCategoryID, `value`, icon)
VALUES				("Apple", 3, 5, "apple.png"), ("Perfume", 1, 50, "perfume.png"), ("Raw Copper", 4, 20, "raw_copper.png"),
					("Wrench", 9, 100, "wrench.png"), ("Oak Plank", 5, 45, "plank.png"), ("Flour", 3, 10, "flour_bag.png"),
                    ("Raw Tin", 4, 15, "raw_tin.png"), ("Brass Ingot", 4, 150, "brass_ingot.png"), ("Copper Ingot", 4, 60, "copper_ingot.png"),
                    ("Apple Pie", 3, 30, "pie.png"), ("Apple Cake", 3, 40,"cake.png"), ("Broken Cogwheel", 8, 5, "broken_cogwheel.png"),
                    ("Brass Cogwheel", 2, 170, "brass_cogwheel.png"), ("Flint and Tinder", 7, 10, "flint.png"), ("Tin Wire", 2, 30, "tin_wire.png"),
                    ("Golden Apple", 3, 50, "golden_apple.png"), ("Rose", 1, 5, "rose.png"), ("Mechanical Hopper", 10, 10000, "hopper.png");

-- Select statement to check the mock data inserted is correct. Join query added for human readability.

SELECT Item.itemID, Item.`name` AS "Item", Item_Category.`name` AS "Category", Item.value, Item.icon FROM Item
JOIN Item_Category ON Item_Category.itemCategoryID = Item.itemCategoryID;

-- Insert statement - inserts items into maps at various locations

INSERT INTO Item_Map (mapID, xCoordinate, yCoordinate, itemID)
VALUES	(2, 1, 10, 1), (2, 15, 10, 17), (2, 1, 20, 1), (2, 2, 20, 12), (2, 15, 18, 5), (3, 2, 10, 7), (3, 4, 5, 12), (3, 4, 6, 15),
		(4, 3, 4, 15), (4, 10, 12, 4), (4, 14, 9, 14), (5, 6, 12, 6), (5, 2, 10, 13), (6, 10, 27, 7), (6, 10, 23, 3), (6, 25, 12, 9),
        (6, 20, 10, 7), (7, 10, 10, 1), (8, 2, 7, 2), (8, 3, 5, 16), (9, 2, 2, 16), (9, 7, 8, 17);

-- Select statement to confirm mock data has been added to Item_Map correctly. Join table for human readability.
-- 
SELECT Map.`name` AS "Map", Item_Map.xCoordinate AS x, Item_Map.yCoordinate AS y, Item.`name` AS Item
FROM Item_Map
JOIN Map ON Map.mapID = Item_Map.mapID
JOIN Item ON Item.itemID = Item_Map.itemID;

-- Adds NPCs to the NPC table, giving them behaviours and linking them to the Character table via characterID
-- TODO - move these into a procedure where the character table and NPC table are populated at once

INSERT INTO NPC (characterID, behaviourID)
VALUES (1, 3), (2, 7), (7, 2);

-- Adds Players to the Player_Character table by adding their characterID and accountID
-- TODO - Move this into a procedure where the character table and player table are populated at once

INSERT INTO Player_Character (characterID, accountID)
VALUES (4, 1), (5, 3), (3, 2), (6, 1);

-- Inserts mock data into the character item table

INSERT INTO Character_Item (characterID, itemID, quantity)
VALUES (1, 1, 2), (2, 12, 3), (1, 12, 2), (7, 1, 2), (2, 10, 3), (6, 11, 2), (1, 8, 2), (6, 12, 3), (5, 12, 17), (7, 13, 16), (3, 15, 2), (2, 14, 4);

-- Select statement that checks to confirm mock data has been added to the Character_Item table successfully

SELECT `Character`.`name`, Item.`name`, Character_Item.quantity
FROM Character_Item
JOIN `Character` ON Character_Item.characterID=`Character`.characterID
JOIN Item ON Item.itemID=Character_Item.itemID;

-- Inserts mock data into the recipe table

INSERT INTO Recipe (itemCraftedID, ingredientID, quantity)
VALUES	(2, 17, 5), (2, 1, 1), (4, 8, 2), (10, 1, 4), (10, 6, 1), (11, 1, 2), (11, 6, 2), (9, 3, 2), (13, 8, 1), (15, 7, 1), (18, 13, 50), (18, 15, 50),
		(18, 5, 5), (18, 9, 5), (18, 8, 5), (8, 3, 2), (8, 7, 1);

-- Select statement - confirms that mock data has been correctly inserted into the recipe table

SELECT itemCrafted.`name` AS "Item Crafted", Item_Category.`name` AS "Category", ingredient.`name` AS "Ingredient", Recipe.quantity AS "Quantity"
FROM Recipe
JOIN Item itemCrafted ON itemCrafted.itemID=Recipe.itemCraftedID
JOIN Item ingredient ON ingredient.itemID=Recipe.ingredientID
JOIN Item_Category ON Item_Category.itemCategoryID = itemCrafted.itemCategoryID
ORDER BY itemCrafted.`name` ASC;

-- Inserts mock data values into Account_Chat - places random accounts into a few different chats.
-- They haven't been carefully selected except to make sure the chats selected are ones not yet associated with maps
-- In future, this should be done as part of a procedure that automatically inserts the correct users to a new chat, instead of hard-coding everything

INSERT INTO Account_Chat(accountID, chatID)
VALUES (1, 10), (1, 11), (1, 12), (1, 13), (1, 14), (1, 15), (1, 16), (1, 17), (2, 13), (2, 14), (2, 10), (3, 11), (3, 12), (3, 13), (4, 14), (4, 17);

-- Insert statement - adds mock data to message table
-- Obviously, this isn't something that we want to hardcode either.

INSERT INTO Message(accountID, chatID, contents)
VALUES	(1, 2, "hi"), (2, 12, "hi"), (3, 3, "hi"), (4, 10, "hello"), (1, 10, "Can someone lend me some Raw Tin?"), (2, 10, "Oh hi"), (3, 3, "hi"),
		(4, 3, "hello"), (1, 7, "hi"), (2, 1, "hi"), (3, 3, "hi"), (4, 10, "Morning");
        
-- Select statement to verify data has been inserted into the Message table correctly

SELECT Message.chatID, `Account`.username, Message.`timestamp`, Message.contents
FROM Message
JOIN `Account` ON `Account`.accountID = Message.accountID
ORDER BY Message.chatID;

-- Insert dummy data into Item_Valuation table

INSERT INTO Item_Valuation(behaviourID, itemCategoryID, perceivedValueModifier, itemSaleModifier)
VALUES	(1, 3, 2.5, 2.5), (1, 1, 1, 0.75), (1,7,1.2,1), (2, 1, 1, 1.15), (2, 2, 0.95, 1.1), (2, 3, 1, 1.1), (2, 4, 0.9, 1.2), (2, 4, 0.9, 1.2), (2, 5, 0.9, 1.2),
		(2, 7, 0.95, 1.1), (2, 8, 0.75, 1.1), (2, 9, 0.9, 1.2), (2, 10, 0.95, 1.15), (3, 9, 1, 0.5), (3, 7, 1, 0.5), (3, 3, 1, 0.5), (4, 3, 1.5, 2), (4, 7, 1.5, 2),
		(5, 5, 1.05, 1.05), (6, 3, 1, 4), (6, 3, 7, 4), (7, 3, 1, 1.5), (7, 8, 1.5, 2), (7, 7, 1.2, 1.6), (7, 4, 1.2, 1.6), (8, 7, 1.1, 1.1), (8, 6, 1.05, 1.1),
		(9, 1, 0.6, 5), (9, 2, 0.6, 5), (9, 3, 0.66, 5), (9, 4, 0.6, 5), (9, 5, 0.6, 5), (9, 6, 0.6, 5), (9, 7, 0.6, 8), (9, 8, 0.6, 5), (9, 10, 0.6, 5);

SELECT NPC_Behaviour.`name`, Item_Category.`name`, perceivedValueModifier, itemSaleModifier FROM Item_Valuation
JOIN NPC_Behaviour ON NPC_Behaviour.behaviourID = Item_Valuation.behaviourID
JOIN Item_Category ON Item_Category.itemCategoryID = Item_Valuation.itemCategoryID
ORDER BY Item_Valuation.behaviourID ASC;

INSERT INTO Player_NPC(npcID, playerID, amicability)
VALUES(1, 3, 100), (1, 4, 100), (1, 6, 100), (1, 5, 100), (7, 3, 50), (2, 6, 25);