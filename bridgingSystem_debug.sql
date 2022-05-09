DROP DATABASE IF EXISTS BridgingSystem_Debug;
CREATE DATABASE IF NOT EXISTS BridgingSystem_Debug;
USE BridgingSystem_Debug;

-- 회원정보를 저장하는 테이블
DROP TABLE IF EXISTS RegisterID;

CREATE TABLE RegisterID (
    UserId          VARCHAR(25) NOT NULL,
    UserPw          VARCHAR(100) NOT NULL,
    LastAccessDate  DATETIME,

    PRIMARY KEY(UserId)
);

CREATE VIEW View_Register AS
SELECT UserId, UserPw, LastAccessDate
FROM RegisterID;

DELIMITER $$ 
CREATE PROCEDURE GetCustomers() -- 전체 고객 목록
BEGIN 
	SELECT * 
    FROM View_Register; 
END $$ 

CREATE PROCEDURE GetOneCustomer(customerNM VARCHAR(25)) -- 회원 찾기
BEGIN 
	SELECT * 
    FROM View_Register
    WHERE UserId = customerNM;
END $$ 

CREATE PROCEDURE Register(userId VARCHAR(25), userPw VARCHAR(25)) -- 회원가입
BEGIN 
	DECLARE nowDate DATETIME;

    SET nowDate = NOW();

    INSERT INTO View_Register VALUES (userId, HEX(AES_ENCRYPT(userPw, userId)), nowDate);
END $$ 

CREATE PROCEDURE ChangeId(oldId VARCHAR(25), newId VARCHAR(25)) -- ID 변경
BEGIN 
    DECLARE nowDate DATETIME;

    SET nowDate = NOW();

    UPDATE View_Register
    SET userId = newId
    WHERE UserId = oldId;
END $$ 

CREATE PROCEDURE ChangePw(targetId VARCHAR(25), newPw VARCHAR(25)) -- 비밀번호 변경
BEGIN 
    DECLARE nowDate DATETIME;

    SET nowDate = NOW();

    UPDATE View_Register
    SET userPw = HEX(AES_ENCRYPT(userPw, userId)), LastAccessDate = nowDate
    WHERE UserId = targetId;
END $$ 
DELIMITER ;

-- 결제정보 로그 테이블
DROP TABLE IF EXISTS PaymentInformation;

CREATE TABLE PaymentInformation (
    Num             INT         NOT NULL,
    SendPlatform    VARCHAR(20) NOT NULL,
    SendUser        VARCHAR(20) NOT NULL,
    SendCurrency    VARCHAR(20) NOT NULL,
    SendTime        VARCHAR(20) NOT NULL,
    SendValue       VARCHAR(20) NOT NULL,

    RecvPlatform    VARCHAR(20) NOT NULL,
    RecvUser        VARCHAR(20) NOT NULL,
    RecvCurrency    VARCHAR(20) NOT NULL,
    RecvTime        VARCHAR(20) NOT NULL,
    RecvValue       VARCHAR(20) NOT NULL,

    Rate            VARCHAR(20),

    PRIMARY KEY(Num)
);

CREATE VIEW View_PaymentInfo AS
SELECT Num, SendPlatform, SendUser, SendCurrency, SendTime, SendValue, RecvPlatform, RecvUser, RecvCurrency, RecvTime, RecvValue, Rate
FROM PaymentInformation;

DELIMITER $$ 
CREATE PROCEDURE GetAllPaymentInfo() -- 전체 거래기록 목록
BEGIN 
	SELECT * 
    FROM View_PaymentInfo; 
END $$ 

CREATE PROCEDURE GetPaymentInfo(Sender VARCHAR(20), Receiver VARCHAR(20)) -- 특정 고객 둘 간의 주문내역
BEGIN 
	SELECT * 
    FROM View_PaymentInfo
    WHERE SendUser = Sender AND RecvUser = Receiver;
END $$ 

CREATE PROCEDURE GetSenderInfo(Sender VARCHAR(20)) -- 특정 송금인의 주문내역
BEGIN 
	SELECT * 
    FROM View_PaymentInfo
    WHERE SendUser = Sender;
END $$ 

CREATE PROCEDURE GetReceiverInfo(Receiver VARCHAR(20)) -- 특정 수취인의 주문내역
BEGIN 
	SELECT * 
    FROM View_PaymentInfo
    WHERE RecvUser = Receiver;
END $$ 

CREATE PROCEDURE PutReceiverInfo(Num INT, SendPlatform VARCHAR(20), SendUser VARCHAR(20), SendCurrency VARCHAR(20), SendTime VARCHAR(20), SendValue VARCHAR(20), RecvPlatform VARCHAR(20), RecvUser VARCHAR(20), RecvCurrency VARCHAR(20), RecvTime VARCHAR(20), RecvValue VARCHAR(20), Rate VARCHAR(20))
BEGIN 
	INSERT INTO View_PaymentInfo
    VALUES (Num, SendPlatform, SendUser, SendCurrency, SendTime, SendValue, RecvPlatform, RecvUser, RecvCurrency, SendTime, SendValue, RecvPlatform);
END $$ 
DELIMITER ;

-- 환율정보 보관 테이블
DROP TABLE IF EXISTS ExchangeRateInformation;

CREATE TABLE ExchangeRateInformation (
    propCurrency        VARCHAR(20) NOT NULL,   -- FROM ~
    stdCurrency         VARCHAR(20) NOT NULL,   -- TO~
    buyRate             VARCHAR(20) NOT NULL,   -- FROM -> TO로 갈때의 가격
    sellRate            VARCHAR(20) NOT NULL,   -- FROM <- TO로 갈때의 가격
    source              VARCHAR(20) NOT NULL,   -- 수집한 플랫폼
    lastModifiedDate    DATETIME NOT NULL,     -- 마지막 수정일자

    PRIMARY KEY(propCurrency, stdCurrency)
);

CREATE VIEW View_Rate AS
SELECT propCurrency, stdCurrency, buyRate, sellRate, source, lastModifiedDate
FROM ExchangeRateInformation;

DELIMITER $$ 
CREATE PROCEDURE GetRates() -- 전체 환율 목록
BEGIN 
	SELECT * 
    FROM View_Rate; 
END $$ 

CREATE PROCEDURE GetOneRate(prop VARCHAR(20), std VARCHAR(20)) -- 특정 고객 둘 간의 주문내역
BEGIN 
	SELECT * 
    FROM View_Rate
    WHERE propCurrency = prop AND stdCurrency = std;
END $$ 

CREATE PROCEDURE GetPropRates(prop VARCHAR(20)) -- prop 기준 검색
BEGIN 
	SELECT * 
    FROM View_Rate
    WHERE propCurrency = prop;
END $$ 

CREATE PROCEDURE GetStdRates(Sender VARCHAR(20)) -- std 기준 검색
BEGIN 
	SELECT * 
    FROM View_Rate
    WHERE stdCurrency = std;
END $$ 

CREATE PROCEDURE GetSource(Receiver VARCHAR(20)) -- 수집 플랫폼 기준 검색
BEGIN 
	SELECT * 
    FROM View_Rate
    WHERE RecvUser = Receiver;
END $$ 

CREATE PROCEDURE PutRate(propCurrency VARCHAR(20), stdCurrency VARCHAR(20), buyRate VARCHAR(20), sellRate VARCHAR(20), source VARCHAR(20), lastModifiedDate DATETIME)
BEGIN 
	INSERT INTO View_Rate
    VALUES (propCurrency, stdCurrency, buyRate, sellRate, source, lastModifiedDate);
END $$ 
DELIMITER ;

DELIMITER $$ 
CREATE PROCEDURE ReplaceAll() -- 전체 변경사항 저장
BEGIN 
    CREATE OR REPLACE VIEW View_Register AS
    SELECT UserId, UserPw, LastAccessDate
    FROM RegisterID;

    CREATE OR REPLACE VIEW View_PaymentInfo AS
    SELECT Num, SendPlatform, SendUser, SendCurrency, SendTime, SendValue, RecvPlatform, RecvUser, RecvCurrency, RecvTime, RecvValue, Rate
    FROM PaymentInformation;

    CREATE OR REPLACE VIEW View_Rate AS
    SELECT propCurrency, stdCurrency, buyRate, sellRate, source, lastModifiedDate
    FROM ExchangeRateInformation;
END $$ 
DELIMITER ;

-- 테스트 데이터 INSERT
INSERT INTO RegisterID VALUES ('koy321', HEX(AES_ENCRYPT('123456', 'koy321')), '2022-05-06 20:41:22');
INSERT INTO RegisterID VALUES ('choi2507', HEX(AES_ENCRYPT('567890', 'choi2507')), '2022-05-06 20:41:22');
INSERT INTO PaymentInformation VALUES (1,'toss','koy321', 'KRW', '202205040208', '10000','toss','choi2507', 'KRW', '202205040211', '10000', '0.0');

-- 사용자생성
-- bridge : 회원정보, 결제정보에만 권한
-- calcRate : 환율정보에만 권한
DROP USER IF EXISTS 'bridge'@'localhost';
DROP USER IF EXISTS 'calcRate'@'localhost';

CREATE USER 'bridge'@'localhost' IDENTIFIED BY 'tsnp2022&&';
GRANT EXECUTE ON PROCEDURE BridgingSystem_Debug.GetCustomers to 'bridge'@'localhost';
GRANT EXECUTE ON PROCEDURE BridgingSystem_Debug.GetOneCustomer to 'bridge'@'localhost';
GRANT EXECUTE ON PROCEDURE BridgingSystem_Debug.Register to 'bridge'@'localhost';
GRANT EXECUTE ON PROCEDURE BridgingSystem_Debug.ChangeId to 'bridge'@'localhost';
GRANT EXECUTE ON PROCEDURE BridgingSystem_Debug.ChangePw to 'bridge'@'localhost';

GRANT EXECUTE ON PROCEDURE BridgingSystem_Debug.GetAllPaymentInfo to 'bridge'@'localhost';
GRANT EXECUTE ON PROCEDURE BridgingSystem_Debug.GetPaymentInfo to 'bridge'@'localhost';
GRANT EXECUTE ON PROCEDURE BridgingSystem_Debug.GetSenderInfo to 'bridge'@'localhost';
GRANT EXECUTE ON PROCEDURE BridgingSystem_Debug.GetReceiverInfo to 'bridge'@'localhost';
GRANT EXECUTE ON PROCEDURE BridgingSystem_Debug.PutReceiverInfo to 'bridge'@'localhost';

CREATE USER 'calcRate'@'localhost' IDENTIFIED BY 'tsnp2022!!';
GRANT EXECUTE ON PROCEDURE BridgingSystem_Debug.GetRates to 'calcRate'@'localhost';
GRANT EXECUTE ON PROCEDURE BridgingSystem_Debug.GetOneRate to 'calcRate'@'localhost';
GRANT EXECUTE ON PROCEDURE BridgingSystem_Debug.GetPropRates to 'calcRate'@'localhost';
GRANT EXECUTE ON PROCEDURE BridgingSystem_Debug.GetStdRates to 'calcRate'@'localhost';
GRANT EXECUTE ON PROCEDURE BridgingSystem_Debug.GetSource to 'calcRate'@'localhost';
GRANT EXECUTE ON PROCEDURE BridgingSystem_Debug.PutRate to 'calcRate'@'localhost';