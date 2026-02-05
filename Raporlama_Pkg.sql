/*
MusteriKredi: Tek bir müşteriye ait kredi bilgilerini tutan kayıt yapısıdır.
MusteriKrediTablo: Birden fazla müşterinin kredi bilgilerini liste halinde tutar.
ToplamKrediListesi: Tüm müşterilerin toplam kredi tutarlarını döndürür.
RiskliMusteriler: Risk skoru yüksek müşterilerin kredi bilgilerini döndürür.
KrediSiralama: Müşterileri toplam kredi tutarına göre sıralı şekilde döndürür.

MusteriRiskAnaliz: Bir müşterinin risk skorunu, kredi dağılımını ve segment bilgisini içeren detaylı analiz kaydıdır.
MusteriRiskAnalizTablo: Birden fazla müşterinin risk analizlerini liste halinde tutar.
DetayliRiskAnalizi: Tüm müşteriler için risk skoru, kredi adedi, ortalama ana para gibi metrikleri içeren detaylı analiz listesini döndürür.

KrediZamanAnaliz: Bir krediye ait zaman serisi bazlı metrikleri (günlük kümülatif, son 30 gün toplamı, son 3 işlem ortalaması vb.) tutan kayıt yapısıdır.
KrediZamanAnalizTablo: Birden fazla kredi için zaman serisi analizlerini liste halinde tutar.
KrediZamanSerisi: Tüm kredilerin zaman bazlı analiz sonuçlarını döndürür.

KrediVolatilite: Bir krediye ait ana para değişimlerinin volatilitesini (son 60 gün standart sapma) içeren kayıt yapısıdır.
KrediVolatiliteTablo: Birden fazla kredi için volatilite analizlerini liste halinde tutar.
KrediVolatiliteAnalizi: Tüm kredilerin volatilite analiz sonuçlarını döndürür.

KrediOzet: Müşteri–şube–yıl kırılımlarına göre kredi toplamlarını tutan çok boyutlu özet kayıt yapısıdır.
KrediOzetTablo: Birden fazla müşteri–şube–yıl kombinasyonuna ait kredi özetlerini liste halinde tutar.
KrediOzet_GroupingSets: Kredi verilerini GROUPING SETS kullanarak farklı kırılım seviyelerinde (detay, şube toplamı, müşteri toplamı, yıl toplamı, genel toplam) çok boyutlu özetler halinde döndürür.
KrediOzet_Rollup: Müşteri-şube-yıl hiyerarşisi boyunca ROLLUP kullanarak kademeli toplamlar üretir. Hiyerarşik raporlar için müşteri, şube ve yıl bazlı toplamları tek sorguda sağlar.
KrediOzet_Cube: Müşteri–şube–yıl kolonlarının tüm kombinasyonlarını CUBE kullanarak hesaplar. OLAP tarzı analizler için tüm detay ve tüm toplam seviyelerini (müşteri toplamı, şube toplamı, yıl toplamı, genel toplam) tek seferde döndürür.

AylikGelirZamanSerisi: Aylık kredi gelirlerini ve kümülatif gelir değerlerini tutan zaman serisi kayıt yapısıdır.
AylikGelirZamanSerisiTablo: Birden fazla aya ait gelir zaman serisi sonuçlarını liste halinde tutar.
GelirZamanSerisi: Aylık kredi gelirlerini hesaplar ve window function kullanarak kümülatif gelir zaman serisini döndürür.

AylikKPI: Aylık bazda toplam kredi, ortalama kredi ve kredi adedi gibi KPI metrik değerlerini tutan kayıt yapısıdır.
AylikKPITablo: Birden fazla aya ait KPI sonuçlarını liste halinde tutar.
AylikKPIAnalizi: Kredi tablosundan aylık bazda toplam kredi, ortalama kredi ve kredi adedi gibi temel KPI’ları hesaplayarak döndürür.

FunnelStep: Kredi sürecindeki adımlara (başvuru, onay, kullanım) ait müşteri sayılarını ve dönüşüm oranlarını tutan kayıt yapısıdır.
FunnelTablo: Funnel analizindeki tüm adımları liste halinde tutar.
KrediFunnelAnalizi: Kredi başvuru-onay-kullanım sürecini funnel mantığıyla analiz eder ve her adım için müşteri sayısı ile dönüşüm oranını döndürür.

CohortAnaliz: Müşterilerin ilk kredi aldıkları aya göre cohort bazlı aktivite sayılarını tutan kayıt yapısıdır.
CohortAnalizTablo: Birden fazla cohort grubunun analiz sonuçlarını liste halinde tutar.
MusteriCohortAnalizi: Müşterilerin ilk kredi aldıkları aya göre cohort oluşturur ve sonraki aylardaki aktivitelerini (retention) analiz eder.
*/

CREATE OR REPLACE PACKAGE Raporlama_Pkg IS

    TYPE MusteriKredi IS RECORD (
        MusteriID   NUMBER,
        Ad          VARCHAR2(50),
        Soyad       VARCHAR2(50),
        ToplamKredi NUMBER,
        KrediSirasi NUMBER
    );

    TYPE MusteriKrediTablo IS TABLE OF MusteriKredi;    

    FUNCTION ToplamKrediListesi RETURN MusteriKrediTablo;

    FUNCTION RiskliMusteriler   RETURN MusteriKrediTablo;
    
    FUNCTION KrediSiralama      RETURN MusteriKrediTablo; 
    
    TYPE MusteriRiskAnaliz IS RECORD (
        MusteriID       NUMBER,
        Ad              VARCHAR2(50),
        Soyad           VARCHAR2(50),
        RiskSkoru       NUMBER,
        ToplamKredi     NUMBER,
        KrediAdedi      NUMBER,
        OrtalamaAnaPara NUMBER,
        MaksimumAnaPara NUMBER,
        KrediSirasi     NUMBER,
        RiskSegmenti    VARCHAR2(10)
    );
    
    TYPE MusteriRiskAnalizTablo IS TABLE OF MusteriRiskAnaliz;

    FUNCTION DetayliRiskAnalizi RETURN MusteriRiskAnalizTablo;
    
    TYPE KrediZamanAnaliz IS RECORD (
        MusteriID       NUMBER,
        KrediID         NUMBER,
        AnaPara         NUMBER,
        VadeBaslangic   DATE,
        GunlukKumulatif NUMBER,
        Son30GunToplam  NUMBER,
        Son3IslemOrt    NUMBER,
        KumulatifMax    NUMBER
    );

    TYPE KrediZamanAnalizTablo IS TABLE OF KrediZamanAnaliz;

    FUNCTION KrediZamanSerisi RETURN KrediZamanAnalizTablo;
    
    TYPE KrediVolatilite IS RECORD (
        MusteriID      NUMBER,
        KrediID        NUMBER,
        Tarih          DATE,
        AnaPara        NUMBER,
        Son60GunStdDev NUMBER
    );

    TYPE KrediVolatiliteTablo IS TABLE OF KrediVolatilite;

    FUNCTION KrediVolatiliteAnalizi RETURN KrediVolatiliteTablo;
    
    TYPE KrediOzet IS RECORD (
        MusteriID     NUMBER,
        SubeID        NUMBER,
        Yil           NUMBER,
        ToplamAnaPara NUMBER,
        GrupTipi      VARCHAR2(30) 
    );

    TYPE KrediOzetTablo IS TABLE OF KrediOzet;

    FUNCTION KrediOzet_GroupingSets RETURN KrediOzetTablo;
    
    FUNCTION KrediOzet_Rollup       RETURN KrediOzetTablo;
    
    FUNCTION KrediOzet_Cube         RETURN KrediOzetTablo;
    
    TYPE AylikGelirZamanSerisi IS RECORD (
        Ay             VARCHAR2(7),
        Gelir          NUMBER,
        KumulatifGelir NUMBER
    );
    
    TYPE AylikGelirZamanSerisiTablo IS TABLE OF AylikGelirZamanSerisi;
    
    FUNCTION GelirZamanSerisi RETURN AylikGelirZamanSerisiTablo;

    TYPE AylikKPI IS RECORD (
        Ay            VARCHAR2(7),
        ToplamKredi   NUMBER,
        OrtalamaKredi NUMBER,
        KrediAdedi    NUMBER
    );
    
    TYPE AylikKPITablo IS TABLE OF AylikKPI;
    
    FUNCTION AylikKPIAnalizi RETURN AylikKPITablo;

    TYPE FunnelStep IS RECORD (
        Adim          VARCHAR2(50),
        MusteriSayisi NUMBER,
        DonusumOrani  NUMBER
    );
    
    TYPE FunnelTablo IS TABLE OF FunnelStep;
    
    FUNCTION KrediFunnelAnalizi RETURN FunnelTablo;

    TYPE CohortAnaliz IS RECORD (
        CohortAy      VARCHAR2(7),
        AyOffset      NUMBER,
        MusteriSayisi NUMBER
    );
    
    TYPE CohortAnalizTablo IS TABLE OF CohortAnaliz;
    
    FUNCTION MusteriCohortAnalizi RETURN CohortAnalizTablo;   

END Raporlama_Pkg;

/* body */

/*
ToplamKrediListesi fonksiyonu, tüm müşterilerin kredi tablolarındaki ana para toplamlarını hesaplayarak MusteriKrediTablo formatında döndürür. LEFT JOIN kullanıldığı için kredisi olmayan müşteriler de sıfır toplam ile listeye dahil edilir.
RiskliMusteriler fonksiyonu, risk skoru 60’tan büyük olan müşterilerin kredi toplamlarını hesaplayarak döndürür. Sadece kredisi olan müşteriler INNER JOIN ile dahil edilir.
KrediSiralama fonksiyonu, müşterilerin toplam kredi tutarlarını hesaplar ve window function (ROW_NUMBER) kullanarak en yüksekten en düşüğe doğru kredi sıralaması oluşturur.
DetayliRiskAnalizi fonksiyonu, müşterilerin kredi adetleri, toplam ana paraları, ortalama ve maksimum kredi tutarları gibi istatistiksel bilgileri üretir. Ayrıca risk skoruna göre LOW–MEDIUM–HIGH segmenti belirlenir ve toplam krediye göre sıralama yapılır.
KrediZamanSerisi fonksiyonu, her kredi için zaman bazlı analiz üretir. Kümülatif toplam, son 30 gün toplamı, son 3 işlem ortalaması ve kümülatif maksimum gibi window function tabanlı zaman serisi metriklerini hesaplar.
KrediVolatiliteAnalizi fonksiyonu, kredilerin ana para değişimlerinin volatilitesini (standart sapma) hesaplar. RANGE BETWEEN INTERVAL '60' DAY PRECEDING kullanılarak son 60 gün içindeki oynaklık hesaplanır ve her müşteri–kredi çifti için döndürülür.

KrediOzet_GroupingSets fonksiyonu, kredi verilerini müşteri–şube–yıl kırılımlarında GROUPING SETS kullanarak çok boyutlu özetler üretir. Böylece farklı seviyelerdeki toplamlar (detay, şube toplamı, müşteri toplamı, yıl toplamı, genel toplam) tek sorguda hesaplanır.
KrediOzet_Rollup fonksiyonu, müşteri-şube-yıl hiyerarşisi boyunca ROLLUP kullanarak kademeli toplamlar oluşturur. Bu fonksiyon özellikle hiyerarşik raporlar için (müşteri bazlı toplam, şube bazlı toplam, yıl bazlı toplam, genel toplam)ideal bir özetleme sağlar.
KrediOzet_Cube fonksiyonu, müşteri–şube–yıl kolonlarının tüm kombinasyonlarını CUBE kullanarak hesaplar. Böylece her boyutun hem tekil hem de birleşik tüm toplamları (detay, müşteri toplamı, şube toplamı, yıl toplamı, genel toplam) otomatik olarak üretilir ve OLAP tarzı analizler için tam kapsamlı bir özet sunar.

GelirZamanSerisi fonksiyonu, aylık kredi gelirlerini hesaplar ve window function kullanarak kümülatif gelir zaman serisini oluşturur. SUM(...) OVER kullanımıyla OLAP tarzı zaman serisi analizi sağlar.
AylikKPIAnalizi fonksiyonu, kredi tablosundan aylık bazda toplam kredi,ortalama kredi ve kredi adedi gibi temel KPI/metrik değerlerini hesaplayarak AylikKPITablo formatında döndürür.
KrediFunnelAnalizi fonksiyonu, kredi başvuru sürecindeki adımları (başvuru,onay, kullanım) funnel mantığıyla analiz eder. Her adım için müşteri sayısı ve dönüşüm oranı hesaplanır.
MusteriCohortAnalizi fonksiyonu, müşterilerin ilk kredi aldıkları aya göre cohort grupları oluşturur ve sonraki aylardaki aktivitelerini analiz ederek retention tablosu üretir.
*/

CREATE OR REPLACE PACKAGE BODY Raporlama_Pkg IS

    FUNCTION ToplamKrediListesi RETURN MusteriKrediTablo IS
        v_Result MusteriKrediTablo;
    BEGIN
        WITH KrediToplam AS (
            SELECT m.MusteriID,
                   m.Ad,
                   m.Soyad,
                   NVL(SUM(k.AnaPara), 0) AS ToplamKredi
            FROM Musteri m
            LEFT JOIN Kredi k ON m.MusteriID = k.MusteriID
            GROUP BY m.MusteriID, m.Ad, m.Soyad
        )
        SELECT MusteriID,
               Ad,
               Soyad,
               ToplamKredi,
               NULL AS KrediSirasi
        BULK COLLECT INTO v_Result
        FROM KrediToplam;

        RETURN v_Result;
    END ToplamKrediListesi;

    FUNCTION RiskliMusteriler RETURN MusteriKrediTablo IS
        v_Result MusteriKrediTablo;
    BEGIN
        SELECT m.MusteriID, 
               m.Ad, 
               m.Soyad, 
               SUM(k.AnaPara) AS ToplamKredi, 
               NULL AS KrediSirasi
        BULK COLLECT INTO v_Result
        FROM Musteri m
        INNER JOIN Kredi k ON m.MusteriID = k.MusteriID
        WHERE m.RiskSkoru > 60
        GROUP BY m.MusteriID, m.Ad, m.Soyad;

        RETURN v_Result;
    END RiskliMusteriler;
    
    -- Window function ile kredi büyüklüğüne göre sıralama
    FUNCTION KrediSiralama RETURN MusteriKrediTablo IS
        v_Result MusteriKrediTablo;
    BEGIN
        WITH KrediToplam AS (
            SELECT m.MusteriID,
                   m.Ad,
                   m.Soyad,
                   NVL(SUM(k.AnaPara), 0) AS ToplamKredi
            FROM Musteri m
            LEFT JOIN Kredi k ON m.MusteriID = k.MusteriID
            GROUP BY m.MusteriID, m.Ad, m.Soyad
        )
        SELECT MusteriID,
               Ad,
               Soyad,
               ToplamKredi,
               ROW_NUMBER() OVER (ORDER BY ToplamKredi DESC) AS KrediSirasi
        BULK COLLECT INTO v_Result
        FROM KrediToplam;

        RETURN v_Result;
    END KrediSiralama;
    
    FUNCTION DetayliRiskAnalizi RETURN MusteriRiskAnalizTablo IS
        v_Result MusteriRiskAnalizTablo;
    BEGIN
        WITH KrediIst AS (
            SELECT m.MusteriID,
                   m.Ad,
                   m.Soyad,
                   m.RiskSkoru,
                   COUNT(k.KrediID)       AS KrediAdedi,
                   NVL(SUM(k.AnaPara), 0) AS ToplamKredi,
                   NVL(AVG(k.AnaPara), 0) AS OrtalamaAnaPara,
                   NVL(MAX(k.AnaPara), 0) AS MaksimumAnaPara
            FROM Musteri m
            LEFT JOIN Kredi k ON m.MusteriID = k.MusteriID
            GROUP BY m.MusteriID, m.Ad, m.Soyad, m.RiskSkoru
        ),
        Skorlu AS (
            SELECT ki.*,
                   CASE 
                       WHEN ki.RiskSkoru < 50 THEN 'LOW'
                       WHEN ki.RiskSkoru BETWEEN 50 AND 60 THEN 'MEDIUM'
                       ELSE 'HIGH'
                   END AS RiskSegmenti
            FROM KrediIst ki
        )
        SELECT MusteriID,
               Ad,
               Soyad,
               RiskSkoru,
               ToplamKredi,
               KrediAdedi,
               OrtalamaAnaPara,
               MaksimumAnaPara,
               ROW_NUMBER() OVER (ORDER BY ToplamKredi DESC) AS KrediSirasi,
               RiskSegmenti
        BULK COLLECT INTO v_Result
        FROM Skorlu;

        RETURN v_Result;

    END DetayliRiskAnalizi;
    
    FUNCTION KrediZamanSerisi RETURN KrediZamanAnalizTablo IS
        v_Result KrediZamanAnalizTablo;
    BEGIN
        WITH KrediData AS (
            SELECT k.KrediID,
                   k.MusteriID,
                   k.AnaPara,
                   k.BasvuruTarihi
            FROM Kredi k
            ORDER BY k.MusteriID, k.BasvuruTarihi
        )
        SELECT MusteriID,
               KrediID,
               AnaPara,
               BasvuruTarihi,
    
               -- Kümülatif toplam (UNBOUNDED PRECEDING) 
               -- GunlukKumulatif, Müşterinin kredilerinin zaman içinde biriken toplamı
               SUM(AnaPara) OVER (
                   PARTITION BY MusteriID
                   ORDER BY BasvuruTarihi
                   ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
               ) AS GunlukKumulatif,

               -- Son 30 gün içindeki toplam (RANGE) 
               -- Son30GunToplam, RANGE ile son 30 gün içindeki kredi hareketi
               SUM(AnaPara) OVER (
                   PARTITION BY MusteriID
                   ORDER BY BasvuruTarihi
                   RANGE BETWEEN INTERVAL '30' DAY PRECEDING AND CURRENT ROW
               ) AS Son30GunToplam,

               -- Son 3 işlem ortalaması (ROWS) 
               -- Son3IslemOrt, ROWS ile son 3 kredi işleminin ortalaması
               AVG(AnaPara) OVER (
                   PARTITION BY MusteriID
                   ORDER BY BasvuruTarihi
                   ROWS BETWEEN 3 PRECEDING AND CURRENT ROW
               ) AS Son3IslemOrt,

               -- Kümülatif maksimum 
               -- KumulatifMax, Müşterinin bugüne kadarki en büyük kredisi
               MAX(AnaPara) OVER (
                   PARTITION BY MusteriID
                   ORDER BY BasvuruTarihi
                   ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
               ) AS KumulatifMax

        BULK COLLECT INTO v_Result
        FROM KrediData;

        RETURN v_Result;

    END KrediZamanSerisi;
    
    -- Kredi ana paralarının volatilitesini hesaplar. 
    -- Volatilite = Standart sapma 
    -- RANGE ile son 60 gün içindeki volatilite hesaplanır.
    FUNCTION KrediVolatiliteAnalizi RETURN KrediVolatiliteTablo IS
        v_Result KrediVolatiliteTablo;
    BEGIN
        WITH KD AS (
            SELECT k.KrediID,
                   k.MusteriID,
                   k.AnaPara,
                   k.BasvuruTarihi AS Tarih
            FROM Kredi k
        )
        SELECT MusteriID,
               KrediID,
               Tarih,
               AnaPara,

               STDDEV(AnaPara) OVER (
                   PARTITION BY MusteriID
                   ORDER BY Tarih
                   RANGE BETWEEN INTERVAL '60' DAY PRECEDING AND CURRENT ROW
               ) AS Son60GunStdDev

        BULK COLLECT INTO v_Result
        FROM KD;

        RETURN v_Result;
        
    END KrediVolatiliteAnalizi;
    
    -- GROUPING SETS ile çok boyutlu kredi özeti
    FUNCTION KrediOzet_GroupingSets RETURN KrediOzetTablo IS
        v_Result KrediOzetTablo;
    BEGIN
        SELECT k.MusteriID,
               m.SubeID,
               EXTRACT(YEAR FROM k.BasvuruTarihi) AS Yil,
               SUM(k.AnaPara) AS ToplamAnaPara,

               CASE 
                   WHEN GROUPING(k.MusteriID)=1 AND GROUPING(m.SubeID)=1 
                        AND GROUPING(EXTRACT(YEAR FROM k.BasvuruTarihi))=1 THEN 'GENEL TOPLAM'
                   WHEN GROUPING(k.MusteriID)=1 AND GROUPING(m.SubeID)=1 THEN 'YIL TOPLAMI'
                   WHEN GROUPING(k.MusteriID)=1 THEN 'SUBE-YIL TOPLAMI'
                   WHEN GROUPING(m.SubeID)=1 THEN 'MUSTERI-YIL TOPLAMI'
                   ELSE 'DETAY'
               END AS GrupTipi

        BULK COLLECT INTO v_Result
        FROM Kredi k
        INNER JOIN Musteri m ON m.MusteriID = k.MusteriID
        
        GROUP BY GROUPING SETS (
            (k.MusteriID, m.SubeID, EXTRACT(YEAR FROM k.BasvuruTarihi)),
            (k.MusteriID, EXTRACT(YEAR FROM k.BasvuruTarihi)),
            (m.SubeID, EXTRACT(YEAR FROM k.BasvuruTarihi)),
            (EXTRACT(YEAR FROM k.BasvuruTarihi)),
            ()
        );

        RETURN v_Result;
    END KrediOzet_GroupingSets;
    
    -- ROLLUP ile hiyerarşik kredi özeti
    FUNCTION KrediOzet_Rollup RETURN KrediOzetTablo IS
        v_Result KrediOzetTablo;
    BEGIN
        SELECT k.MusteriID,
               m.SubeID,
               EXTRACT(YEAR FROM k.BasvuruTarihi) AS Yil,
               SUM(k.AnaPara) AS ToplamAnaPara,

               CASE 
                   WHEN GROUPING(k.MusteriID)=1 AND GROUPING(m.SubeID)=1 
                        AND GROUPING(EXTRACT(YEAR FROM k.BasvuruTarihi))=1 THEN 'GENEL TOPLAM'
                   WHEN GROUPING(m.SubeID)=1 AND GROUPING(k.MusteriID)=1 
                        THEN 'YIL TOPLAMI'
                   WHEN GROUPING(k.MusteriID)=1 THEN 'SUBE TOPLAMI'
                   ELSE 'DETAY'
               END AS GrupTipi

        BULK COLLECT INTO v_Result
        FROM Kredi k
        INNER JOIN Musteri m ON m.MusteriID = k.MusteriID
        
        GROUP BY ROLLUP (EXTRACT(YEAR FROM k.BasvuruTarihi), m.SubeID, k.MusteriID );

        RETURN v_Result;
    END KrediOzet_Rollup;
    
    -- CUBE ile tüm kombinasyonların kredi özeti
    FUNCTION KrediOzet_Cube RETURN KrediOzetTablo IS
        v_Result KrediOzetTablo;
    BEGIN
        SELECT k.MusteriID,
               m.SubeID,
               EXTRACT(YEAR FROM k.BasvuruTarihi) AS Yil,
               SUM(k.AnaPara) AS ToplamAnaPara,

               CASE 
                   WHEN GROUPING(k.MusteriID)=1 AND GROUPING(m.SubeID)=1 
                        AND GROUPING(EXTRACT(YEAR FROM k.BasvuruTarihi))=1 THEN 'GENEL TOPLAM'
                   WHEN GROUPING(k.MusteriID)=1 AND GROUPING(m.SubeID)=1 THEN 'YIL TOPLAMI'
                   WHEN GROUPING(k.MusteriID)=1 AND GROUPING(EXTRACT(YEAR FROM k.BasvuruTarihi))=1 THEN 'SUBE TOPLAMI'
                   WHEN GROUPING(m.SubeID)=1 AND GROUPING(EXTRACT(YEAR FROM k.BasvuruTarihi))=1 THEN 'MUSTERI TOPLAMI'                   
                   WHEN GROUPING(k.MusteriID)=1 THEN 'SUBE-YIL TOPLAMI'
                   WHEN GROUPING(m.SubeID)=1 THEN 'MUSTERI-YIL TOPLAMI'
                   WHEN GROUPING(EXTRACT(YEAR FROM k.BasvuruTarihi))=1 THEN 'MUSTERI-SUBE TOPLAMI'                                     
                   ELSE 'DETAY'
               END AS GrupTipi

        BULK COLLECT INTO v_Result
        FROM Kredi k
        INNER JOIN Musteri m ON m.MusteriID = k.MusteriID
        
        GROUP BY CUBE (k.MusteriID, m.SubeID, EXTRACT(YEAR FROM k.BasvuruTarihi));

        RETURN v_Result;
    END KrediOzet_Cube;
    
    -- Aylık gelir, Kümülatif gelir hesaplar
    FUNCTION GelirZamanSerisi RETURN AylikGelirZamanSerisiTablo IS
        v_Result AylikGelirZamanSerisiTablo;
    BEGIN
        SELECT TO_CHAR(BasvuruTarihi, 'YYYY-MM') AS Ay,
               SUM(AnaPara) AS Gelir,
               SUM(SUM(AnaPara)) OVER (
                   ORDER BY TO_CHAR(BasvuruTarihi, 'YYYY-MM')
               ) AS KumulatifGelir
        BULK COLLECT INTO v_Result
        FROM Kredi        
        GROUP BY TO_CHAR(BasvuruTarihi, 'YYYY-MM')
        ORDER BY Ay;

        RETURN v_Result;
    END GelirZamanSerisi;
    
    -- Aylık kredi KPI’ları- Toplam kredi, Ortalama kredi, Kredi adedi hesaplar
    FUNCTION AylikKPIAnalizi RETURN AylikKPITablo IS
        v_Result AylikKPITablo;
    BEGIN
        SELECT TO_CHAR(BasvuruTarihi, 'YYYY-MM') AS Ay,
               SUM(AnaPara) AS ToplamKredi,
               AVG(AnaPara) AS OrtalamaKredi,
               COUNT(*) AS KrediAdedi
        BULK COLLECT INTO v_Result
        FROM Kredi
        GROUP BY TO_CHAR(BasvuruTarihi, 'YYYY-MM')
        ORDER BY Ay;

        RETURN v_Result;
    END AylikKPIAnalizi;
    
    --Başvuru yapan, Onaylanan , Kredi kullanan müşteriler ile Dönüşüm oranı hesaplar
    FUNCTION KrediFunnelAnalizi RETURN FunnelTablo IS
        v_Result FunnelTablo;
    BEGIN
        WITH F AS (
            SELECT 'Basvuru' AS Adim, 
                   COUNT(*)  AS MusteriSayisi 
            FROM Kredi
            UNION ALL
            SELECT 'Onay', 
                   COUNT(*) 
            FROM Kredi WHERE Durum = 'AKTIF'
            UNION ALL
            SELECT 'Kullanim', 
                   COUNT(*) 
            FROM Kredi WHERE Durum = 'KAPANDI'
        )
        SELECT Adim,
               MusteriSayisi,
               ROUND(MusteriSayisi / FIRST_VALUE(MusteriSayisi) OVER (), 4) AS DonusumOrani
        BULK COLLECT INTO v_Result
        FROM F;

        RETURN v_Result;
    END KrediFunnelAnalizi;

    -- Müşterilerin ilk kredi aldığı aya göre cohort,retention analizi
    FUNCTION MusteriCohortAnalizi RETURN CohortAnalizTablo IS
        v_Result CohortAnalizTablo;
    BEGIN
        WITH IlkKredi AS (
            SELECT MusteriID,
                   MIN(TO_CHAR(BasvuruTarihi, 'YYYY-MM')) AS CohortAy
            FROM Kredi
            GROUP BY MusteriID
        ),
        Aktivite AS (
            SELECT i.CohortAy,
                   TO_CHAR(k.BasvuruTarihi, 'YYYY-MM') AS AktifAy,
                   MONTHS_BETWEEN(
                       TO_DATE(TO_CHAR(k.BasvuruTarihi, 'YYYY-MM'), 'YYYY-MM'),
                       TO_DATE(i.CohortAy, 'YYYY-MM')
                   ) AS AyOffset
            FROM IlkKredi i
            INNER JOIN Kredi k ON k.MusteriID = i.MusteriID
        )
        SELECT CohortAy,
               AyOffset,
               COUNT(*) AS MusteriSayisi
        BULK COLLECT INTO v_Result
        FROM Aktivite
        GROUP BY CohortAy, AyOffset
        ORDER BY CohortAy, AyOffset;

        RETURN v_Result;
    END MusteriCohortAnalizi;

END Raporlama_Pkg;


/* kodları çalıştırma*/

-- ToplamKrediListesi
SET SERVEROUTPUT ON;
DECLARE
    v_List Raporlama_Pkg.MusteriKrediTablo;
BEGIN
    -- Fonksiyonu çağırıp tabloyu alıyoruz
    v_List := Raporlama_Pkg.ToplamKrediListesi;

    -- 10 000 müşteriyi yazdırıyoruz
    FOR i IN 1 .. LEAST(v_List.COUNT, 10000) LOOP
        DBMS_OUTPUT.PUT_LINE( 'MusteriID: ' || v_List(i).MusteriID || 
            ' | Ad: ' || v_List(i).Ad || 
            ' | Soyad: ' || v_List(i).Soyad || 
            ' | ToplamKredi: ' || v_List(i).ToplamKredi);
    END LOOP;
END;
/

-- RiskliMusteriler fonksiyonu boş dönüyordu çünkü, Musteri tablosundaki müşterilerin RiskSkoru hepsinin 0 dı
-- Alarm tablosundaki yüksek riskli müşteriler için, Musteri tablosunda RiskSkoru nu 70 olarak güncelledim.
DECLARE
    v_Affected NUMBER;
BEGIN
    UPDATE Musteri m
       SET m.RiskSkoru = 70
     WHERE m.Durum = 'AKTIF'
       AND EXISTS (
               SELECT 1
                 FROM Alarm a
                WHERE a.MusteriID = m.MusteriID
                  AND a.Durum = 'AKTIF'
           );

    v_Affected := SQL%ROWCOUNT;

    DBMS_OUTPUT.PUT_LINE('Güncellenen müşteri sayısı: ' || v_Affected);

    COMMIT;
END;
/

-- RiskliMusteriler
DECLARE
    v_List Raporlama_Pkg.MusteriKrediTablo;
BEGIN
    v_List := Raporlama_Pkg.RiskliMusteriler;

    -- 1500 müşteri var
    FOR i IN 1 .. LEAST(v_List.COUNT, 10000) LOOP
        DBMS_OUTPUT.PUT_LINE(
            'MusteriID: ' || v_List(i).MusteriID ||
            ' | Ad: ' || v_List(i).Ad ||
            ' | Soyad: ' || v_List(i).Soyad ||
            ' | ToplamKredi: ' || v_List(i).ToplamKredi );
    END LOOP;
END;
/

-- KrediSiralama
DECLARE
    v_List Raporlama_Pkg.MusteriKrediTablo;
BEGIN
    v_List := Raporlama_Pkg.KrediSiralama;

    -- 10.000 müşteri var
    FOR i IN 1 .. LEAST(v_List.COUNT, 10000) LOOP
        DBMS_OUTPUT.PUT_LINE( 'Sira: ' || v_List(i).KrediSirasi || 
            ' | MusteriID: ' || v_List(i).MusteriID || 
            ' | Ad: ' || v_List(i).Ad ||
            ' | Soyad: ' || v_List(i).Soyad || 
            ' | ToplamKredi: ' || v_List(i).ToplamKredi );
    END LOOP;
END;
/

-- DetayliRiskAnalizi
DECLARE
    v_List Raporlama_Pkg.MusteriRiskAnalizTablo;
BEGIN
    v_List := Raporlama_Pkg.DetayliRiskAnalizi;

    -- 10.000 müşteri var
    FOR i IN 1 .. LEAST(v_List.COUNT, 1000) LOOP
        DBMS_OUTPUT.PUT_LINE( 'MusteriID: ' || v_List(i).MusteriID || 
            ' | RiskSkoru: ' || v_List(i).RiskSkoru ||
            ' | ToplamKredi: ' || v_List(i).ToplamKredi ||
            ' | KrediAdedi: ' || v_List(i).KrediAdedi ||
            ' | Ortalama: ' || v_List(i).OrtalamaAnaPara ||
            ' | Max: ' || v_List(i).MaksimumAnaPara ||
            ' | Sira: ' || v_List(i).KrediSirasi ||
            ' | Segment: ' || v_List(i).RiskSegmenti );
    END LOOP;
END;
/

-- KrediZamanSerisi
DECLARE
    v_List Raporlama_Pkg.KrediZamanAnalizTablo;
BEGIN
    v_List := Raporlama_Pkg.KrediZamanSerisi;

    -- 6000 kredi var
    FOR i IN 1 .. LEAST(v_List.COUNT, 10000) LOOP
        DBMS_OUTPUT.PUT_LINE(
            'MusteriID: ' || v_List(i).MusteriID ||
            ' | KrediID: ' || v_List(i).KrediID ||
            ' | AnaPara: ' || v_List(i).AnaPara ||
            ' | GunlukKumulatif: ' || v_List(i).GunlukKumulatif ||
            ' | Son30GunToplam: ' || v_List(i).Son30GunToplam ||
            ' | Son3IslemOrt: ' || v_List(i).Son3IslemOrt ||
            ' | KumulatifMax: ' || v_List(i).KumulatifMax );
    END LOOP;
END;
/

-- KrediVolatiliteAnalizi
DECLARE
    v_List Raporlama_Pkg.KrediVolatiliteTablo;
BEGIN
    v_List := Raporlama_Pkg.KrediVolatiliteAnalizi;

    -- 6000 kredi var
    FOR i IN 1 .. LEAST(v_List.COUNT, 10000) LOOP
        DBMS_OUTPUT.PUT_LINE(
            'MusteriID: ' || v_List(i).MusteriID ||
            ' | KrediID: ' || v_List(i).KrediID ||
            ' | AnaPara: ' || v_List(i).AnaPara ||
            ' | Tarih: ' || TO_CHAR(v_List(i).Tarih, 'YYYY-MM-DD') ||
            ' | Son60GunStdDev: ' || v_List(i).Son60GunStdDev );
    END LOOP;
END;
/

-- KrediOzet_GroupingSets
SET SERVEROUTPUT ON;
DECLARE
    v_List Raporlama_Pkg.KrediOzetTablo;
BEGIN
    v_List := Raporlama_Pkg.KrediOzet_GroupingSets;

    -- 12012 gruplama var
    FOR i IN 1 .. LEAST(v_List.COUNT, 10000) LOOP
        DBMS_OUTPUT.PUT_LINE(
            'MusteriID: ' || NVL(TO_CHAR(v_List(i).MusteriID), 'NULL') ||
            ' | SubeID: ' || NVL(TO_CHAR(v_List(i).SubeID), 'NULL') ||
            ' | Yil: ' || NVL(TO_CHAR(v_List(i).Yil), 'NULL') ||
            ' | ToplamAnaPara: ' || v_List(i).ToplamAnaPara ||
            ' | GrupTipi: ' || v_List(i).GrupTipi
        );
    END LOOP;
END;
/

-- KrediOzet_Rollup
SET SERVEROUTPUT ON;
DECLARE
    v_List Raporlama_Pkg.KrediOzetTablo;
BEGIN
    v_List := Raporlama_Pkg.KrediOzet_Rollup;

    -- 6012 rollup var
    FOR i IN 1 .. LEAST(v_List.COUNT, 10000) LOOP
        DBMS_OUTPUT.PUT_LINE(
            'MusteriID: ' || NVL(TO_CHAR(v_List(i).MusteriID), 'NULL') ||
            ' | SubeID: ' || NVL(TO_CHAR(v_List(i).SubeID), 'NULL') ||
            ' | Yil: ' || NVL(TO_CHAR(v_List(i).Yil), 'NULL') ||
            ' | ToplamAnaPara: ' || v_List(i).ToplamAnaPara ||
            ' | GrupTipi: ' || v_List(i).GrupTipi
        );
    END LOOP;
END;
/

-- KrediOzet_Cube
SET SERVEROUTPUT ON;
DECLARE
    v_List Raporlama_Pkg.KrediOzetTablo;
BEGIN
    v_List := Raporlama_Pkg.KrediOzet_Cube;

    -- 24.022 eşleşme var
    FOR i IN 1 .. LEAST(v_List.COUNT, 10000) LOOP
        DBMS_OUTPUT.PUT_LINE(
            'MusteriID: ' || NVL(TO_CHAR(v_List(i).MusteriID), 'NULL') ||
            ' | SubeID: ' || NVL(TO_CHAR(v_List(i).SubeID), 'NULL') ||
            ' | Yil: ' || NVL(TO_CHAR(v_List(i).Yil), 'NULL') ||
            ' | ToplamAnaPara: ' || v_List(i).ToplamAnaPara ||
            ' | GrupTipi: ' || v_List(i).GrupTipi
        );
    END LOOP;
END;
/

-- AylikKPIAnalizi
SET SERVEROUTPUT ON;
DECLARE
    v_List Raporlama_Pkg.AylikKPITablo;
BEGIN
    v_List := Raporlama_Pkg.AylikKPIAnalizi;

    -- 1 satır veri var
    FOR i IN 1 .. LEAST(v_List.COUNT, 100) LOOP
        DBMS_OUTPUT.PUT_LINE(
            'Ay: ' || v_List(i).Ay ||
            ' | ToplamKredi: ' || v_List(i).ToplamKredi ||
            ' | OrtalamaKredi: ' || v_List(i).OrtalamaKredi ||
            ' | KrediAdedi: ' || v_List(i).KrediAdedi
        );
    END LOOP;
END;
/

-- KrediFunnelAnalizi
SET SERVEROUTPUT ON;
DECLARE
    v_List Raporlama_Pkg.FunnelTablo;
BEGIN
    v_List := Raporlama_Pkg.KrediFunnelAnalizi;

    -- 3 satır veri var
    FOR i IN 1 .. LEAST(v_List.COUNT, 1000) LOOP
        DBMS_OUTPUT.PUT_LINE(
            'Adim: ' || v_List(i).Adim ||
            ' | MusteriSayisi: ' || v_List(i).MusteriSayisi ||
            ' | DonusumOrani: ' || v_List(i).DonusumOrani
        );
    END LOOP;
END;
/

-- MusteriCohortAnalizi
SET SERVEROUTPUT ON;
DECLARE
    v_List Raporlama_Pkg.CohortAnalizTablo;
BEGIN
    v_List := Raporlama_Pkg.MusteriCohortAnalizi;

    -- 1 satır veri var
    FOR i IN 1 .. LEAST(v_List.COUNT, 100) LOOP
        DBMS_OUTPUT.PUT_LINE(
            'CohortAy: ' || v_List(i).CohortAy ||
            ' | AyOffset: ' || v_List(i).AyOffset ||
            ' | MusteriSayisi: ' || v_List(i).MusteriSayisi
        );
    END LOOP;
END;
/

-- GelirZamanSerisi
SET SERVEROUTPUT ON;
DECLARE
    v_List Raporlama_Pkg.AylikGelirZamanSerisiTablo;
BEGIN
    v_List := Raporlama_Pkg.GelirZamanSerisi;

    -- 1 satır veri var
    FOR i IN 1 .. LEAST(v_List.COUNT, 100) LOOP
        DBMS_OUTPUT.PUT_LINE(
            'Ay: ' || v_List(i).Ay ||
            ' | Gelir: ' || v_List(i).Gelir ||
            ' | KumulatifGelir: ' || v_List(i).KumulatifGelir
        );
    END LOOP;
END;
/

--view bölümü
--REFRESH FAST ON COMMIT idi REFRESH COMPLETE ON DEMAND yaptım
BEGIN
    EXECUTE IMMEDIATE '
        CREATE MATERIALIZED VIEW MV_KrediZaman
        BUILD IMMEDIATE
        REFRESH COMPLETE ON DEMAND
        AS
        SELECT
            k.KrediID,
            k.MusteriID,
            k.AnaPara,
            k.BasvuruTarihi,

            SUM(k.AnaPara) OVER (
                PARTITION BY k.MusteriID
                ORDER BY k.BasvuruTarihi
                ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
            ) AS GunlukKumulatif,

            SUM(k.AnaPara) OVER (
                PARTITION BY k.MusteriID
                ORDER BY k.BasvuruTarihi
                RANGE BETWEEN INTERVAL ''30'' DAY PRECEDING AND CURRENT ROW
            ) AS Son30GunToplam,

            AVG(k.AnaPara) OVER (
                PARTITION BY k.MusteriID
                ORDER BY k.BasvuruTarihi
                ROWS BETWEEN 3 PRECEDING AND CURRENT ROW
            ) AS Son3IslemOrt,

            MAX(k.AnaPara) OVER (
                PARTITION BY k.MusteriID
                ORDER BY k.BasvuruTarihi
                ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
            ) AS KumulatifMax

        FROM Kredi k
    ';
END;
/

SELECT * FROM MV_KrediZaman; --view çalıştırma

--REFRESH FAST ON COMMIT çalışması için MV LOG gerekir,REFRESH FAST diyorsan Oracle senden şunu ister:
CREATE MATERIALIZED VIEW LOG ON Kredi
WITH ROWID, SEQUENCE (KrediID, MusteriID, AnaPara, BasvuruTarihi)
INCLUDING NEW VALUES;
--Bunu yapmazsan MV oluşturulur ama FAST REFRESH çalışmaz, Oracle otomatik olarak COMPLETE REFRESH’e düşer.
--Materialized View (MV) – Pipeline-ready -Zaman serisi analizleri genelde ağırdır. Bu yüzden MV kullanılır.
--FAST REFRESH → performanslı  
--ON COMMIT → veri güncel  
--Window function’lar MV içinde  
--Pipeline’da çalıştırılabilir  
--Idempotent (hata vermez)

-- Zaman serisi hesaplarını cache'leyen MV
CREATE MATERIALIZED VIEW MV_KrediStage
BUILD IMMEDIATE
REFRESH COMPLETE ON DEMAND
AS
SELECT 
    k.KrediID,
    k.MusteriID,
    k.AnaPara,
    k.BasvuruTarihi,
    SUM(k.AnaPara) OVER (
        PARTITION BY k.MusteriID 
        ORDER BY k.BasvuruTarihi 
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS GunlukKumulatif,
    SUM(k.AnaPara) OVER (
        PARTITION BY k.MusteriID 
        ORDER BY k.BasvuruTarihi 
        RANGE BETWEEN INTERVAL '30' DAY PRECEDING AND CURRENT ROW
    ) AS Son30GunToplam,
    AVG(k.AnaPara) OVER (
        PARTITION BY k.MusteriID 
        ORDER BY k.BasvuruTarihi 
        ROWS BETWEEN 3 PRECEDING AND CURRENT ROW
    ) AS Son3IslemOrt,
    MAX(k.AnaPara) OVER (
        PARTITION BY k.MusteriID 
        ORDER BY k.BasvuruTarihi 
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS KumulatifMax
FROM Kredi k;

SELECT * FROM MV_KrediStage;

CREATE OR REPLACE VIEW VW_RiskAnaliz AS
SELECT
    m.MusteriID,
    m.Ad,
    m.Soyad,
    m.RiskSkoru,
    mv.Son30GunToplam,
    mv.Son3IslemOrt,
    mv.KumulatifMax,
    CASE
        WHEN m.RiskSkoru < 50 THEN 'LOW'
        WHEN m.RiskSkoru BETWEEN 50 AND 60 THEN 'MEDIUM'
        ELSE 'HIGH'
    END AS RiskSegmenti
FROM Musteri m
LEFT JOIN MV_KrediStage mv 
       ON m.MusteriID = mv.MusteriID;
 
SELECT * FROM VW_RiskAnaliz;

-- Parquet dosyasını external table olarak tanımlama
CREATE EXTERNAL TABLE ParquetSiparisler
(
    SiparisID INT,
    MusteriID INT,
    SiparisTarihi DATE,
    Tutar DECIMAL(10,2)
)
WITH (
    LOCATION = 'C:\Users\User\Desktop\GitHub\QueryBank',
    DATA_SOURCE = MyDataLake,
    FILE_FORMAT = ParquetFileFormat
);