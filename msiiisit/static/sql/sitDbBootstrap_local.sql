/*
	File name: 		issueTrackDbTableCreate.sql
	Purpose:		Create tables required for service issue tracking application database.
	Date Created:	02 May 2019
	Author:			Michael R. Brown
*/

/* Service Issue Tracking Database */
/* drop database if exists sitDb; */
create database if not exists sitDb; /* Local */
use sitDb; /* Local */

/*
	Table for capturing users of the application: clients, management and administrators.
*/
select 'Creating tblAccounts table...' as 'Action';
create table if not exists tblAccounts
						(
						acctId 				    int(5) zerofill not null auto_increment primary key,
						email					varchar(128) not null unique,
						surname				    varchar(40) not null,
						firstName				varchar(40) not null,
						maudindo				tinyint(1) unsigned not null default '1',
						addrLine1	 			varchar(40),
						addrLine2 				varchar(40),
                        addrLine3       		varchar(40),
						addrCity 				varchar(40),
						addrCounty 				varchar(40),
                        postcode     			varchar(12),
						addrCountryISO			char(2) not null default 'GB',
						phone					varchar(20),
						mobilePhone				varchar(20), 
						abtrusus				varchar(128) not null,
						isActive    			tinyint(1) unsigned not null default '1',
						lastTimeIn				datetime,
						dateAdded				datetime not null,
						dateModified			datetime not null
						) engine=InnoDB default charset=utf8;

/*
	Categories table. Every issue that is created is assigned a category. Upon initiation of development,
	the categories were as such: Something needs fixing, Complaint, Suggestion, Question, Comment.
    Because of the relationship between tblCat and tblIssue, we do not allow a deletion of categories
    through the UI. They however, can make it inactive.
*/
select 'Creating tblCat table...' as 'Action';
create table if not exists tblCat
						(
						catId 					tinyint(3) zerofill not null auto_increment primary key,
						catName					varchar(30) not null unique,
						catDesc					varchar(60),
                        catActive               tinyint(1) unsigned not null default '1', /* Is this category selectable */
						dateAdded				datetime not null,
						dateModified			datetime not null
						) engine=InnoDB auto_increment=10 default charset=utf8;

/*
	Issues table. Table for capturing issues. At time of project start, the types of issues that
	could be logged by customers/clients were: Something needs fixing, complaint, suggestion, question or comment.
    Note: setting the description fields to varchars as opposed to text fields because of potentially fulltext
    indexing those fields -- for an innoDb, fulltexted index varchar fields are much faster than text fields
*/
select 'Creating tblIssue table...' as 'Action';
create table if not exists tblIssue
						(
						issueId 				int(6) zerofill not null auto_increment primary key,
						issueSubj				varchar(30) not null,
						issueDesc				varchar(1000), /* Setting this as a varchar because may want to full text index. This would be faster than setting to a text field */
						catId					tinyint(3) zerofill not null,
						urgent					tinyint(1) unsigned not null default '0',
						acctId				    int(5) zerofill not null, /* Person who submitted issue */
						issueStatus				tinyint(1) unsigned not null default '0' comment '0=not viewed, 1=viewed, 2=resolved', /* Not viewed means it hasn't been viewed by property management */
						dateViewed			    datetime,
						dateResolved			datetime,
						markedResolvedBy		int(5) zerofill,
						resolutionDesc			varchar(1000), /* See above comment */
						dateAdded				datetime not null,
						dateModified			datetime not null,
						index (acctId),
						index (dateAdded),
						index (dateResolved),
						foreign key fk_catId(catId)
							references tblCat(catId)
							on update no action
							on delete cascade
						) engine=InnoDB auto_increment=10000 default charset=utf8;

/*
	Comments table. Table for capturing comments to issues.
*/
select 'Creating tblComments table...' as 'Action';
create table if not exists tblComments
						(
						commId 					int(6) zerofill not null auto_increment primary key,
						comment					varchar(1000),
						issueId					int(6) zerofill not null, /* This acts as a thread id */
						acctId				    int(5) zerofill not null, /* Person who posted comment */
						dateAdded				datetime not null,
						dateModified			datetime not null,
						foreign key fk_issueId(issueId)
							references tblIssue(issueId)
							on update no action
							on delete cascade
						) engine=InnoDB auto_increment=1000 default charset=utf8;

/*
    Insert test accounts. Note: Michael is an administrator; maudindo=255
    The password is password for both accounts.
*/
select 'Inserting account records...' as 'Action';
insert into tblAccounts (acctId, email, surname, firstName, maudindo, addrLine1, addrCity, postCode, mobilePhone, abtrusus, dateAdded, dateModified)
values
(1, "mb@mb.com", "Brown", "Michael", 255, "Flat 23", "London", "W3 0RG", "+44 (0) 7777 878787", "pbkdf2:sha256:150000$vabZ3a7F$619e1453737c19428febcc4650b780522ff3aa15f701a742ae468d1cd135e7f5", NOW(), NOW()),
(2, "kb@kb.com", "Brown", "Kelly", 1, "Flat 23", "London", "W3 0RG", "+44 (0) 8888 878787", "pbkdf2:sha256:150000$vabZ3a7F$619e1453737c19428febcc4650b780522ff3aa15f701a742ae468d1cd135e7f5", NOW(), NOW());

/*
    Insert issue category records.
*/
select 'Inserting category records...' as 'Action';
insert into tblCat (catId, catName, catDesc, catActive, dateAdded, dateModified)
values
(10, "Repair", "Repair or service request", 1, NOW(), NOW()),
(11, "Complaint", "Complaint about service", 1, NOW(), NOW()),
(12, "Suggestion", "Suggestion for improved service", 1, NOW(), NOW()),
(13, "Question", "Question regarding service", 1, NOW(), NOW()),
(14, "Comment", "Comment on service", 1, NOW(), NOW());

/*
    Insert issues.
*/
select 'Inserting issue records...' as 'Action';
insert into tblIssue (issueId, issueSubj, issueDesc, catId, urgent, acctId, dateAdded, dateModified)
values
(10000, "Toilet is leaking", "En-Suite toilet is leaking all over the floor. And it stinks!", 10, 1, 1, NOW(), NOW()),
(10001, "No hot water", "We have no hot water anywhere", 10, 1, 2, NOW(), NOW()),
(10002, "Concierge", "It would be good if the building had a concierge. They could accept packages on our behalf.", 12, 0, 2, NOW(), NOW()),
(10003, "Noisy neighbours", "The neighbours above us are extremely loud. They were singing on their balcony until 3:00 am yesterday!", 11, 0, 1, NOW(), NOW()),
(10004, "Thank you", "Appreciate that you dealt with the fly-tipping issue", 14, 0, 2, NOW(), NOW());

