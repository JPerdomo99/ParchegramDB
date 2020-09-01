CREATE TRIGGER DeleteUserAction ON [User]
INSTEAD OF DELETE
AS
BEGIN
	DECLARE @userDeletedId INT;
	SELECT @userDeletedId = deleted.Id FROM deleted;
	IF EXISTS (SELECT * FROM Follow WHERE IdUserFollower = @userDeletedId OR IdUserFollower = @userDeletedId)
		DELETE FROM [Like] WHERE IdUser = @userDeletedId;
		DELETE FROM [Comment] WHERE IdUser = @userDeletedId;
		DELETE FROM [Post] WHERE IdUser = @userDeletedId;
		DELETE FROM [Follow] WHERE IdUserFollower = @userDeletedId OR IdUserFollowing = @userDeletedId;
		DELETE FROM [User] WHERE Id = @userDeletedId;
END;

DROP TRIGGER DeleteUserAction

CREATE TRIGGER DeletePostAction ON [Post]
INSTEAD OF DELETE 
AS 
BEGIN
	DECLARE @postDeleteId INT;
	SELECT @postDeleteId = deleted.Id FROM deleted;
	DELETE FROM [Share] WHERE IdPost = @postDeleteId;
	DELETE FROM [Comment] WHERE IdPost = @postDeleteId;
	DELETE FROM [Like] WHERE IdPost = @postDeleteId;
	DELETE FROM [LogPost] WHERE IdPost = @postDeleteId;
	DELETE FROM [Post] WHERE Id = @postDeleteId;
END;

DROP TRIGGER DeletePostAction

--USE TestRedSocial;

CREATE TABLE [User] (
	Id INT PRIMARY KEY IDENTITY,
	NameUser VARCHAR(40) NOT NULL,
	Email VARCHAR(100) NOT NULL,
	password VARCHAR(64) NOT NULL,
	DateBirth DATE NOT NULL
);

CREATE TABLE TypePost (
	Id INT PRIMARY KEY IDENTITY,
	Description VARCHAR(30) NOT NULL,
);

CREATE TABLE Post (
	Id INT PRIMARY KEY IDENTITY,
	Description VARCHAR(3000),
	IdUser INT,
	IdTypePost INT,
	PathFile VARCHAR(1000),
	-- Foreign key
	CONSTRAINT FK_Post_User FOREIGN KEY (IdUser)
	REFERENCES [User](Id),
	CONSTRAINT FK_Post_TypePost FOREIGN KEY (IdTypePost)
	REFERENCES TypePost(Id)
);

CREATE TABLE Share (
	IdUser INT,
	IdPost INT,
	CONSTRAINT FK_Share_User FOREIGN KEY (IdUser)
	REFERENCES [User](Id),
	CONSTRAINT FK_Share_Post FOREIGN KEY (IdPost)
	REFERENCES Post(Id)
);

CREATE TABLE [Like] (
	IdUser INT,
	IdPost INT,
	CONSTRAINT FK_Like_User FOREIGN KEY (IdUser)
	REFERENCES [User](Id),
	CONSTRAINT FK_Like_Post FOREIGN KEY (IdPost)
	REFERENCES Post(Id)
);

alter table [Like] add constraint PK_Like primary key clustered (IdUser, IdPost);

CREATE TABLE Comment (
	IdUser INT,
	IdPost INT,
	CommentText NVARCHAR(1200),
	CONSTRAINT FK_Comment_User FOREIGN KEY (IdUser)
	REFERENCES [User](Id),
	CONSTRAINT FK_Comment_Post FOREIGN KEY (IdPost)
	REFERENCES Post(Id)
);

CREATE TABLE Follow (
	IdUserFollower INT NOT NULL,
	IdUserFollowing INT NOT NULL,
	CONSTRAINT FK_Follow_UserFollower FOREIGN KEY (IdUserFollower)
	REFERENCES [User](Id),
	CONSTRAINT FK_Follow_UserFollowing FOREIGN KEY (IdUserFollowing)
	REFERENCES [User](Id)
);

ALTER TABLE Follow 
	ADD CONSTRAINT PK_Follow PRIMARY KEY CLUSTERED([IdUserFollower], [IdUserFollowing]);

-- Pruebas del trigger que se dispara al eliminar un usuario hasta el momento prueba exitosa
--INSERT INTO [User] VALUES('atehortua199', 'atehortua199@gmail.com', 'julian1999');
--INSERT INTO [User] VALUES('carmen', 'carmen1985@gmail.com', 'carmen85');
--INSERT INTO [User] VALUES('Jimena', 'jime88@outlook.com', 'jimena88');
--INSERT INTO [User] VALUES('Oscar', 'oscar@oscar.com', 'oscaroscar');

---- atehortua199 sigue a oscar y a jimena
--INSERT INTO Follow VALUES(27, 30);
--INSERT INTO Follow VALUES(27, 29);

---- carmen y oscar sigue a atehortua199
--INSERT INTO Follow VALUES(28, 27);
--INSERT INTO Follow VALUES(30, 27);

---- Deberían eliminarse todos los registros
--SELECT * FROM [User];
--SELECT * FROM Follow;
--GO 
--DELETE FROM [User] WHERE Id = 27;
--GO
--SELECT * FROM [User];
--SELECT * FROM Follow;

ALTER TABLE [User] ADD DateBirth DATE NOT NULL;

select * from Post
	left join Follow on Follow.IdUserFollowing = Post.IdUser and Follow.IdUserFollower = 1
	left join Share on Share.IdPost = Post.Id or Share.IdUser = Follow.IdUserFollowing and Share.IdUser = 1 
	left join [User] on [User].Id = Post.IdUser
where Post.IdUser = Follow.IdUserFollowing or Post.Id = Share.IdPost
order by Share.[Date] desc, Post.[Date] desc;

--select * from Post
--	inner join Follow on Follow.IdUserFollower = 1
--	inner join Share on Share.IdUser = 1
--	inner join [User] on [User].Id = Post.IdUser
--where Post.IdUser = Follow.IdUserFollowing or Post.Id = Share.IdPost
--order by Post.[Date] desc;

select * from LogPost
	left join Post on Post.Id = LogPost.IdPost
	left join [User] on [User].Id = Post.IdUser -- El dueño del post
	left join [Share] on [Share].IdPost = LogPost.IdPost
	left join [User] S on S.Id = Share.IdUser --El que compartio
where LogPost.IdUser = 1
order by LogPost.[Date] desc;

create table LogPost (
	IdUser int not null,
	IdPost int not null,
	Date datetime not null,
	primary key (IdUser, IdPost),
	constraint FK_LogPost_User foreign key (IdUser)
	references [User](Id),
	constraint FK_LogPost_Post foreign key (IdPost)
	references Post(Id)
);

--select * from Post
--	left join Follow on Follow.IdUserFollowing = Post.IdUser and Follow.IdUserFollower = 1
--	left join [User] on [User].Id = Follow.IdUserFollowing
--	left join Share on Share.IdUser = [User].Id
--where Follow.IdUserFollower = 1

select * from [Follow]
	left join [Share] on [Share].IdUser = [Follow].IdUserFollowing
	left join [Post] on [Post].IdUser = [Follow].IdUserFollowing or [Post].Id = [Share].IdPost
	left join [User] on [User].Id = [Post].IdUser
	left join [User] u on u.Id = [Share].IdUser
where [Follow].IdUserFollower = 1;

select * from [Post]
select * from [Share]
select * from [User]

select * from [Post]
	left join [Follow] on [Follow].IdUserFollowing = [Post].IdUser and [Follow].IdUserFollower = 1
	left join [Share] on [Share].IdPost = [Post].Id
	left join [User] on [User].Id = [Post].IdUser
	left join [User] u on u.Id = [Share].IdUser
where [Follow].IdUserFollower = 1 or [Post].Id = [Share].IdPost

select * from [Post]
select * from [Share]

select * from [Post]
	left join [Share] on [Share].IdPost = [Post].Id
	left join [Follow] on [Follow].IdUserFollowing = [Post].IdUser
where [Follow].IdUserFollower = 1 or [Post].Id = [Share].IdPost

select * from Follow where IdUserFollower = 1;
select * from Share where IdUser = 2;

-----------------------------------
select * from [Post]
	inner join [User] on [User].Id = [Post].IdUser -- Autor del post
	left join [Share] on [Share].IdPost = [Post].Id  -- Si el post fue compartido
	left join [Follow] on [Follow].IdUserFollowing = [Post].IdUser -- El registro del follow del usuario que sigo que es dueño de un post para la primera condición del where
	left join [User] u on u.Id = [Share].IdUser -- El amigo que sigo que compartio el post
	left join [Like] on [Like].IdPost = [Post].Id
where [Follow].IdUserFollower = 1 or [Share].IdUser in
													(select IdUserFollowing from [Follow] where [IdUserFollower] = 1)
													-- Si el que compartio es amigo del usuario
								  or [Like].IdUser = 1;

select * from [User];

select * from [Follow]
	right outer join [Share] on [Share].IdUser = [Follow].IdUserFollowing
	right outer join [Post] on [Post].IdUser = [Follow].IdUserFollowing or [Post].Id = [Share].IdPost
	join [User] on [User].Id = [Post].IdUser
where IdUserFollower = 1

select * from Comment;
insert into Comment values(1, 6, 'Comentario de prueba 1', GETDATE());
insert into Comment values(1002, 6, 'Comentario de prueba 2', GETDATE());
insert into Comment values(1003, 6, 'Comentario de prueba 3', GETDATE());
insert into Comment values(1, 10, 'Comentario de prueba 1', GETDATE());

insert into [Like] values(1, 1014)
Latin1_General_CI_AI

alter database ParchegramDB collate Latin1_General_CI_AI;
ALTER DATABASE ParchegramDB
SET MULTI_USER;

alter table [Post] alter column [Description] nvarchar(3000) collate Latin1_General_CI_AI;
alter table [Comment] alter column [CommentText] nvarchar(1200) collate Latin1_General_CI_AI not null;

update [Post] set Description = N'??????????????????' where Id = 1014;
select * from [Post];

select * from [Post];