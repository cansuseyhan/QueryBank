/*
HesapTuru: Vadeli, Vadesiz, Döviz vb.
FaizOrani: Hesap türüne ait faiz oranı
Tarih: Değişiklik yaptığımız günün tarihi
*/

CREATE TABLE FaizOranlari (
    HesapTuru VARCHAR2(20),
    FaizOrani NUMBER(5,2)  NOT NULL,
    Tarih     DATE
);

/*
GunSonuFaizIslemleri: Gün sonu faiz işlemlerini topluca yürütür
FaizGuncelle: FaizOranlarini random bir şekilde günceller ve tabloya insert eder.
*/

CREATE OR REPLACE PACKAGE Faiz_Pkg IS

    PROCEDURE GunSonuFaizIslemleri;
    PROCEDURE FaizGuncelle; 

END Faiz_Pkg;

/* body*/

CREATE OR REPLACE PACKAGE BODY Faiz_Pkg IS

    PROCEDURE GunSonuFaizIslemleri IS
        -- Açık durumdaki tüm hesapları seçen cursor
        CURSOR hesap_cursor IS
            SELECT HesapNo, Bakiye, HesapTuru, FaizOrani
            FROM   Hesap 
            WHERE  Durum = 'AÇIK';
        
        v_faizMiktari NUMBER;     -- Günlük faiz tutarı        
    BEGIN
        -- Tüm açık hesapları tek tek dolaş
        FOR hesap_rec IN hesap_cursor LOOP            

            -- Günlük faiz hesaplama: Yıllık faiz / 365
            v_faizMiktari := hesap_rec.Bakiye * hesap_rec.FaizOrani / 100 / 365;

            -- İşlem kaydı oluştur (faiz yatırma)
            Islem_Pkg.ParaYatir(hesap_rec.HesapNo, v_faizMiktari);            
           
        END LOOP;
    END GunSonuFaizIslemleri;
    
    PROCEDURE FaizGuncelle IS
    v_Vadesiz NUMBER;
    v_Vadeli  NUMBER;
    v_Doviz   NUMBER;
    
    BEGIN
        -- Her hesap türü için bir faiz oranı üretme
        v_Vadesiz := ROUND(DBMS_RANDOM.VALUE(0, 1), 2);
        v_Vadeli  := ROUND(DBMS_RANDOM.VALUE(30, 50), 2);
        v_Doviz   := ROUND(DBMS_RANDOM.VALUE(3, 9), 2);

        -- Hesap tablosundaki hesapları toplu güncelleme
        UPDATE Hesap
        SET FaizOrani = v_Vadesiz
        WHERE HesapTuru = 'VADESIZ'
          AND Durum = 'AÇIK';

        UPDATE Hesap
        SET FaizOrani = v_Vadeli
        WHERE HesapTuru = 'VADELI'
          AND Durum = 'AÇIK';

        UPDATE Hesap
        SET FaizOrani = v_Doviz
        WHERE HesapTuru = 'DOVIZ'
          AND Durum = 'AÇIK';

        -- FaizOranlari tablosuna ekleme
        INSERT INTO FaizOranlari (HesapTuru, FaizOrani, Tarih)
        VALUES ('VADESIZ', v_Vadesiz, NULL);

        INSERT INTO FaizOranlari (HesapTuru, FaizOrani, Tarih)
        VALUES ('VADELI', v_Vadeli, NULL);

        INSERT INTO FaizOranlari (HesapTuru, FaizOrani, Tarih)
        VALUES ('DOVIZ', v_Doviz, NULL);
        
    COMMIT;
    
    -- Gün sonu faiz işlemlerini çalıştırma
    GunSonuFaizIslemleri;

    END FaizGuncelle;       

END Faiz_Pkg;

/* Trigger ile FaizOranları güncellenirse tarih bilgisi giriyoruz */
CREATE TRIGGER trg_faiz_tarih
BEFORE INSERT OR UPDATE ON FaizOranlari
FOR EACH ROW
BEGIN
    IF :NEW.Tarih IS NULL THEN
        :NEW.Tarih := SYSDATE;
    END IF;
END;
/

-- Oracle daki bir bug dan dolayı, oluşturduğum trigger daki sondaki END IF, END gibi satırları kaydetmedi.
--Bu yüzden trigger hep INVALID kalıyor.
--Oracle bazen CREATE TRIGGER komutunu doğrudan çalıştırınca kodu kesiyor.Ama EXECUTE IMMEDIATE ile oluşturunca asla kesmiyor.
--Trigger’ı PL/SQL blok içinde oluşturursan trigger tam ve eksiksiz kaydedilir.
-- Oracle kodu tek parça olarak alıyor, Trigger VALID olarak kaydediliyor
--Bu yüzden de profesyonel Oracle DBA’lar trigger’ları genellikle EXECUTE IMMEDIATE ile oluşturur.

BEGIN
    EXECUTE IMMEDIATE '
        CREATE TRIGGER trg_faiz_tarih
        BEFORE INSERT OR UPDATE ON FaizOranlari
        FOR EACH ROW
        BEGIN
            IF :NEW.Tarih IS NULL THEN
                :NEW.Tarih := SYSDATE;
            END IF;
        END;
    ';
END;
/

/* kodları çalıştırma*/

-- Öncelikle, Hesap tablosunda bütün Hesap Türleri VADESIZ di onu güncelliyoruz random olarak
-- Faiz Oranlarının hepsi aynıydı random bir şekilde değiştiriyoruz

DECLARE
    v_HesapTuru  VARCHAR2(20);
    v_FaizOrani  NUMBER;
BEGIN
    FOR r IN (
        SELECT HesapNo
        FROM Hesap
        WHERE Durum = 'AÇIK'
    ) LOOP

        CASE
            WHEN DBMS_RANDOM.VALUE < 0.33 THEN
                v_HesapTuru := 'VADESIZ';
                v_FaizOrani := 4.50;

            WHEN DBMS_RANDOM.VALUE < 0.66 THEN
                v_HesapTuru := 'VADELI';
                v_FaizOrani := 46.00;

            ELSE
                v_HesapTuru := 'DOVIZ';
                v_FaizOrani := 4.70;
        END CASE;

        -- Güncelleme
        UPDATE Hesap
        SET HesapTuru = v_HesapTuru,
            FaizOrani = v_FaizOrani
        WHERE HesapNo = r.HesapNo;

    END LOOP;

    COMMIT;
END;
/

-- Daha sonra o faiz oranlarını FaizOranlari tablosuna insert ediyoruz
INSERT INTO FaizOranlari (HesapTuru, FaizOrani, Tarih) VALUES ('VADESIZ', 1.5 , SYSDATE);
INSERT INTO FaizOranlari (HesapTuru, FaizOrani, Tarih) VALUES ('VADELI', 36, SYSDATE);
INSERT INTO FaizOranlari (HesapTuru, FaizOrani, Tarih) VALUES ('DOVIZ', 5.7 , SYSDATE);

-- Prosedürü çalıştırma
BEGIN
    Faiz_Pkg.GunSonuFaizIslemleri;
END;

BEGIN
    Faiz_Pkg.FaizGuncelle;
END;

SELECT * FROM FaizOranlari;


-- trigger body sini görmek için
SELECT trigger_body
FROM user_triggers
WHERE trigger_name = 'TRG_FAIZ_TARIH';

-- trigger da hata kontrolü
SHOW ERRORS TRIGGER trg_faiz_tarih;

-- trigger invalid mi valid mi kontrolü
SELECT status FROM user_objects WHERE object_name = 'TRG_FAIZ_TARIH';

-- trigger enabled mı kontrolü
SELECT trigger_name, status FROM user_triggers WHERE trigger_name = 'TRG_FAIZ_TARIH';

-- trigger ve bağlı olduğu tablo doğru şema da mı kontrolü
SELECT owner, table_name 
FROM all_tables
WHERE table_name = 'FAIZORANLARI';

SELECT owner, trigger_name, table_name, status
FROM all_triggers
WHERE trigger_name = 'TRG_FAIZ_TARIH';