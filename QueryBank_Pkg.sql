--  İşlemTipi: 'MUSTERI_AC', 'MUSTERI_PASIFET', 'HESAP_AC', 'HESAP_KAPAT', 'BAKIYE_GUNCELLE', 'BAKIYE_SORGULA'
-- 'PARA_YATIR', 'PARA_CEK','TRANSFER_YAP', 'KART_AC', 'KART_ISLEM', 'KART_BAKIYE', 'KART_KAPAT',
-- 'KREDI_BASVURU', 'KREDI_ODEME', 'SWIFT_TRANSFER', 'KUR_GUNCELLE', 'FAIZ_GUNCELLE', 'RISK_KONTROL', 'ALARM_KAPAT',
-- 'RAPORLAMA', 'KULLANICI_EKLE', 'KULLANICI_DOGRULA', 'KULLANICI_PASIFET'

/* 
TumIslemleriYap prosedürü,İşlemTipi ne göre ilgili modülü çağırıp, log kaydı tutup,hata fırlatan,
tek merkezden tüm müşteri, hesap, işlem, kart, kredi, swift, faiz, alarm, kullanıcı ve raporlama işlemlerini yöneten sistemdir. 
*/


CREATE OR REPLACE PACKAGE QueryBank_Pkg IS

    PROCEDURE TumIslemleriYap(
        p_IslemTipi     VARCHAR2,
        p_MusteriID     NUMBER   DEFAULT NULL,
        p_HesapNo       NUMBER   DEFAULT NULL,
        p_KartNo        NUMBER   DEFAULT NULL,
        p_Tutar         NUMBER   DEFAULT NULL,
        p_KrediID       NUMBER   DEFAULT NULL,
        p_AliciIBAN     VARCHAR2 DEFAULT NULL,
        p_KartTuru      VARCHAR2 DEFAULT NULL,
        p_Ad            VARCHAR2 DEFAULT NULL,
        p_Soyad         VARCHAR2 DEFAULT NULL,
        p_TCNo          CHAR     DEFAULT NULL,
        p_Dogum         DATE     DEFAULT NULL,
        p_SubeID        NUMBER   DEFAULT NULL,
        p_HedefHesapNo  NUMBER   DEFAULT NULL,
        p_SonKullanma   DATE     DEFAULT NULL,
        p_KartCvc       CHAR     DEFAULT NULL,
        p_AlarmID       NUMBER   DEFAULT NULL,
        p_YeniKur       NUMBER   DEFAULT NULL,
        p_KullaniciAdi  VARCHAR2 DEFAULT NULL,
        p_Sifre         VARCHAR2 DEFAULT NULL,
        p_Rol           VARCHAR2 DEFAULT NULL,
        p_KullaniciID   NUMBER   DEFAULT NULL,
        p_KartIslemTipi VARCHAR2 DEFAULT NULL
    );

END QueryBank_Pkg;
/

/* body */

CREATE OR REPLACE PACKAGE BODY QueryBank_Pkg IS

    PROCEDURE TumIslemleriYap(
        p_IslemTipi     VARCHAR2,
        p_MusteriID     NUMBER   DEFAULT NULL,
        p_HesapNo       NUMBER   DEFAULT NULL,
        p_KartNo        NUMBER   DEFAULT NULL,
        p_Tutar         NUMBER   DEFAULT NULL,
        p_KrediID       NUMBER   DEFAULT NULL,
        p_AliciIBAN     VARCHAR2 DEFAULT NULL,
        p_KartTuru      VARCHAR2 DEFAULT NULL,
        p_Ad            VARCHAR2 DEFAULT NULL,
        p_Soyad         VARCHAR2 DEFAULT NULL,
        p_TCNo          CHAR     DEFAULT NULL,
        p_Dogum         DATE     DEFAULT NULL,
        p_SubeID        NUMBER   DEFAULT NULL,
        p_HedefHesapNo  NUMBER   DEFAULT NULL,
        p_SonKullanma   DATE     DEFAULT NULL,
        p_KartCvc       CHAR     DEFAULT NULL,
        p_AlarmID       NUMBER   DEFAULT NULL,
        p_YeniKur       NUMBER   DEFAULT NULL,
        p_KullaniciAdi  VARCHAR2 DEFAULT NULL,
        p_Sifre         VARCHAR2 DEFAULT NULL,
        p_Rol           VARCHAR2 DEFAULT NULL,
        p_KullaniciID   NUMBER   DEFAULT NULL,
        p_KartIslemTipi VARCHAR2 DEFAULT NULL
    ) IS
        v_KrediID        NUMBER;
        v_MusteriID      NUMBER;
        v_HesapNo        NUMBER;
        v_Bakiye         NUMBER;
        v_KartNo         NUMBER;
        v_KalanLimit     NUMBER;
        v_KullaniciIDOUT NUMBER;
        v_Dogrulama      BOOLEAN;
    BEGIN
        CASE p_IslemTipi

            WHEN 'MUSTERI_AC' THEN
                IF p_Ad IS NULL OR p_Soyad IS NULL OR p_TCNo IS NULL OR p_Dogum IS NULL OR p_SubeID IS NULL THEN
                    RAISE_APPLICATION_ERROR(-20001, 'MUSTERI_AC için tüm müşteri bilgileri gerekli.');
                END IF;
                Musteri_Pkg.MusteriAc(p_Ad, p_Soyad, p_TCNo, p_Dogum, p_SubeID, v_MusteriID);
                Alarm_Pkg.RiskSkoruKontrolEt(v_MusteriID); -- risk kontrolü otomatik
                Log_Pkg.LogBilgi('Yeni müşteri açıldı, MusteriID:'||v_MusteriID, 'Musteri_Pkg', v_MusteriID);

            WHEN 'MUSTERI_PASIFET' THEN
                IF p_MusteriID IS NULL THEN
                    RAISE_APPLICATION_ERROR(-20002, 'MUSTERI_PASIFET için MusteriID gerekli.');
                END IF;
                Musteri_Pkg.MusteriPasifEt(p_MusteriID);
                Log_Pkg.LogUyari('Müşteri pasif hale getirildi, MusteriID:'||p_MusteriID, 'Musteri_Pkg', p_MusteriID);                
            
            WHEN 'HESAP_AC' THEN
                IF p_MusteriID IS NULL OR p_SubeID IS NULL OR p_KartTuru IS NULL THEN
                    RAISE_APPLICATION_ERROR(-20003, 'HESAP_AC için MusteriID, SubeID ve KartTuru gerekli.');
                END IF;
                Hesap_Pkg.HesapAc(p_MusteriID, p_SubeID, p_KartTuru, NVL(p_Tutar,0), v_HesapNo);
                Log_Pkg.LogBilgi('Yeni hesap açıldı, HesapNo:'||v_HesapNo, 'Hesap_Pkg', p_MusteriID);

            WHEN 'HESAP_KAPAT' THEN
                IF p_HesapNo IS NULL THEN
                    RAISE_APPLICATION_ERROR(-20004, 'HESAP_KAPAT için HesapNo gerekli.');
                END IF;
                Hesap_Pkg.HesapKapat(p_HesapNo);
                Log_Pkg.LogUyari('Hesap kapatıldı, HesapNo:'||p_HesapNo, 'Hesap_Pkg', p_MusteriID);

            WHEN 'BAKIYE_GUNCELLE' THEN
                IF p_HesapNo IS NULL OR p_Tutar IS NULL THEN
                    RAISE_APPLICATION_ERROR(-20005, 'BAKIYE_GUNCELLE için HesapNo ve Tutar gerekli.');
                END IF;
                Hesap_Pkg.BakiyeGuncelle(p_HesapNo, p_Tutar);
                Log_Pkg.LogBilgi('Bakiye güncellendi, HesapNo:'||p_HesapNo||' Tutar:'||p_Tutar, 'Hesap_Pkg', p_MusteriID);

            WHEN 'BAKIYE_SORGULA' THEN
                IF p_HesapNo IS NULL THEN
                    RAISE_APPLICATION_ERROR(-20006, 'BAKIYE_SORGULA için HesapNo gerekli.');
                END IF;
                v_Bakiye := Hesap_Pkg.BakiyeSorgula(p_HesapNo);
                Log_Pkg.LogBilgi('Bakiye sorgulandı, HesapNo:'||p_HesapNo||' Bakiye:'||v_Bakiye, 'Hesap_Pkg', p_MusteriID);
    
            WHEN 'PARA_YATIR' THEN
                IF p_HesapNo IS NULL OR p_Tutar IS NULL THEN
                    RAISE_APPLICATION_ERROR(-20007, 'PARA_YATIR için HesapNo ve Tutar gerekli.');
                END IF;
                Islem_Pkg.ParaYatir(p_HesapNo, p_Tutar);
                Log_Pkg.LogBilgi('Para yatırıldı', 'Islem_Pkg', p_MusteriID);

            WHEN 'PARA_CEK' THEN
                IF p_HesapNo IS NULL OR p_Tutar IS NULL THEN
                    RAISE_APPLICATION_ERROR(-20008, 'PARA_CEK için HesapNo ve Tutar gerekli.');
                END IF;
                Islem_Pkg.ParaCek(p_HesapNo, p_Tutar);
                Log_Pkg.LogBilgi('Para çekildi', 'Islem_Pkg', p_MusteriID);                
            
            WHEN 'TRANSFER_YAP' THEN
                IF p_HesapNo IS NULL OR p_HedefHesapNo IS NULL OR p_Tutar IS NULL THEN
                    RAISE_APPLICATION_ERROR(-20009, 'TRANSFER_YAP için Kaynak Hesap, Hedef Hesap ve Tutar gerekli.');
                END IF;
                BEGIN
                    Islem_Pkg.TransferYap(p_HesapNo, p_HedefHesapNo, p_Tutar);
                    Log_Pkg.LogBilgi('Transfer yapıldı, Kaynak Hesap:'||p_HesapNo||' Hedef Hesap:'||p_HedefHesapNo||' Tutar:'||p_Tutar, 'Islem_Pkg', p_MusteriID);
                EXCEPTION
                    WHEN OTHERS THEN
                        Log_Pkg.LogHata(SQLERRM, SQLCODE, 'Islem_Pkg', p_MusteriID);
                        RAISE;
                END;               
            
            WHEN 'KART_AC' THEN
                IF p_MusteriID IS NULL OR p_HesapNo IS NULL OR p_KartTuru IS NULL OR p_SonKullanma IS NULL OR p_KartCvc IS NULL THEN
                    RAISE_APPLICATION_ERROR(-20010, 'KART_AC için MusteriID, HesapNo, KartTuru, SonKullanma ve CVC gerekli.');
                END IF;
                Kart_Pkg.KartAc(p_MusteriID, p_HesapNo, p_KartTuru, NVL(p_Tutar,5000), p_SonKullanma, p_KartCvc, v_KartNo);
                Log_Pkg.LogBilgi('Yeni kart açıldı, KartNo:'||v_KartNo, 'Kart_Pkg', p_MusteriID);            

            WHEN 'KART_ISLEM' THEN
                IF p_KartNo IS NULL OR p_Tutar IS NULL OR p_KartIslemTipi IS NULL THEN
                    RAISE_APPLICATION_ERROR(-20011, 'KART_ISLEM için KartNo, Tutar ve KartIslemTipi gerekli.');
                END IF;
                Kart_Pkg.KartIslemYap(p_KartNo, p_Tutar, p_KartIslemTipi); 
                Log_Pkg.LogBilgi('Kart işlemi yapıldı, KartNo:'||p_KartNo||' Tutar:'||p_Tutar||' Tip:'||p_KartIslemTipi, 'Kart_Pkg', p_MusteriID);                
            
            WHEN 'KART_BAKIYE' THEN
                IF p_KartNo IS NULL THEN
                    RAISE_APPLICATION_ERROR(-20012, 'KART_BAKIYE için KartNo gerekli.');
                END IF;
                v_KalanLimit := Kart_Pkg.KartBakiyeSorgula(p_KartNo);
                Log_Pkg.LogBilgi('Kart bakiye sorgulandı, KartNo:'||p_KartNo||' KalanLimit:'||v_KalanLimit, 'Kart_Pkg', p_MusteriID);
           
            WHEN 'KART_KAPAT' THEN
                IF p_KartNo IS NULL THEN
                    RAISE_APPLICATION_ERROR(-20013, 'KART_KAPAT için KartNo gerekli.');
                END IF;
                Kart_Pkg.KartKapat(p_KartNo);
                Log_Pkg.LogUyari('Kart kapatıldı, KartNo:'||p_KartNo, 'Kart_Pkg', p_MusteriID);

            WHEN 'KREDI_BASVURU' THEN
                IF p_MusteriID IS NULL OR p_Tutar IS NULL THEN
                    RAISE_APPLICATION_ERROR(-20014, 'KREDI_BASVURU için MusteriID ve Tutar gerekli.');
                END IF;
                Kredi_Pkg.KrediBasvuru(p_MusteriID, p_Tutar, 1.5, SYSDATE+365, v_KrediID);
                Alarm_Pkg.RiskSkoruKontrolEt(p_MusteriID); -- risk kontrolü
                Log_Pkg.LogBilgi('Kredi başvurusu yapıldı, KrediID:'||v_KrediID, 'Kredi_Pkg', p_MusteriID);

            WHEN 'KREDI_ODEME' THEN
                IF p_KrediID IS NULL OR p_Tutar IS NULL THEN
                    RAISE_APPLICATION_ERROR(-20015, 'KREDI_ODEME için KrediID ve Tutar gerekli.');
                END IF;
                Kredi_Pkg.KrediOdeme(p_KrediID, p_Tutar);
                Log_Pkg.LogBilgi('Kredi ödemesi yapıldı, KrediID:'||p_KrediID, 'Kredi_Pkg', p_MusteriID);

            WHEN 'SWIFT_TRANSFER' THEN
                IF p_HesapNo IS NULL OR p_AliciIBAN IS NULL OR p_Tutar IS NULL THEN
                    RAISE_APPLICATION_ERROR(-20016, 'SWIFT_TRANSFER için HesapNo, AliciIBAN ve Tutar gerekli.');
                END IF;
                Swift_Pkg.SwiftTransfer(p_HesapNo, p_AliciIBAN, p_Tutar);
                Log_Pkg.LogBilgi('SWIFT transfer yapıldı', 'Swift_Pkg', p_MusteriID);                
            
            WHEN 'KUR_GUNCELLE' THEN
                IF p_YeniKur IS NULL THEN
                    RAISE_APPLICATION_ERROR(-20017, 'KUR_GUNCELLE için YeniKur değeri gerekli.');
                END IF;
                BEGIN
                    Swift_Pkg.KurGuncelle(p_YeniKur);
                    Log_Pkg.LogBilgi('Kur güncellendi, YeniKur:'||p_YeniKur, 'Swift_Pkg');
                EXCEPTION
                    WHEN OTHERS THEN
                        Log_Pkg.LogHata(SQLERRM, SQLCODE, 'Swift_Pkg');
                        RAISE;
                END;

            WHEN 'FAIZ_GUNCELLE' THEN
                Faiz_Pkg.FaizGuncelle;
                Log_Pkg.LogBilgi('Faiz oranları güncellendi', 'Faiz_Pkg');

            WHEN 'RISK_KONTROL' THEN
                IF p_MusteriID IS NULL THEN
                    RAISE_APPLICATION_ERROR(-20018, 'RISK_KONTROL için MusteriID gerekli.');
                END IF;
                Alarm_Pkg.RiskSkoruKontrolEt(p_MusteriID);
                Log_Pkg.LogBilgi('Risk kontrolü yapıldı', 'Alarm_Pkg', p_MusteriID);                
           
            WHEN 'ALARM_KAPAT' THEN
                IF p_AlarmID IS NULL THEN
                    RAISE_APPLICATION_ERROR(-20019, 'ALARM_KAPAT için AlarmID gerekli.');
                END IF;
                BEGIN
                    Alarm_Pkg.AlarmKapat(p_AlarmID);
                    Log_Pkg.LogBilgi('Alarm kapatıldı, AlarmID:'||p_AlarmID, 'Alarm_Pkg', p_MusteriID);
                EXCEPTION
                    WHEN OTHERS THEN
                        Log_Pkg.LogHata(SQLERRM, SQLCODE, 'Alarm_Pkg', p_MusteriID);
                        RAISE;
                END;
                
            WHEN 'KULLANICI_EKLE' THEN
                IF p_KullaniciAdi IS NULL OR p_Sifre IS NULL OR p_Rol IS NULL THEN
                    RAISE_APPLICATION_ERROR(-20020, 'KULLANICI_EKLE için KullaniciAdi, Sifre ve Rol gerekli.');
                END IF;
                Kullanici_Pkg.KullaniciEkle(p_KullaniciAdi, p_Sifre, p_Rol, v_KullaniciIDOut);
                Log_Pkg.LogBilgi('Yeni kullanıcı eklendi, KullaniciID:'||v_KullaniciIDOut, 'Kullanici_Pkg');                

            WHEN 'KULLANICI_DOGRULA' THEN
                IF p_KullaniciAdi IS NULL OR p_Sifre IS NULL THEN
                    RAISE_APPLICATION_ERROR(-20021, 'KULLANICI_DOGRULA için KullaniciAdi ve Sifre gerekli.');
                END IF;
                v_Dogrulama := Kullanici_Pkg.KullaniciDogrula(p_KullaniciAdi, p_Sifre);
                IF v_Dogrulama THEN
                    Log_Pkg.LogBilgi('Kullanıcı doğrulandı: '||p_KullaniciAdi, 'Kullanici_Pkg');
                ELSE
                    Log_Pkg.LogUyari('Kullanıcı doğrulama başarısız: '||p_KullaniciAdi, 'Kullanici_Pkg');
                END IF;

            WHEN 'KULLANICI_PASIFET' THEN
                IF p_KullaniciID IS NULL THEN
                    RAISE_APPLICATION_ERROR(-20022, 'KULLANICI_PASIFET için KullaniciID gerekli.');
                END IF;
                Kullanici_Pkg.KullaniciPasifEt(p_KullaniciID);
                Log_Pkg.LogUyari('Kullanıcı pasif hale getirildi, KullaniciID:'||p_KullaniciID, 'Kullanici_Pkg');
                
            WHEN 'RAPORLAMA' THEN
                DECLARE
                    v_ToplamKredi   Raporlama_Pkg.MusteriKrediTablo;
                    v_RiskliMusteri Raporlama_Pkg.MusteriKrediTablo;
                    v_KrediSiralama Raporlama_Pkg.MusteriKrediTablo;
                    v_RiskAnaliz    Raporlama_Pkg.MusteriRiskAnalizTablo;
                    v_ZamanAnaliz   Raporlama_Pkg.KrediZamanAnalizTablo;
                    v_Volatilite    Raporlama_Pkg.KrediVolatiliteTablo;
                    v_OzetGS        Raporlama_Pkg.KrediOzetTablo;
                    v_OzetRollup    Raporlama_Pkg.KrediOzetTablo;
                    v_OzetCube      Raporlama_Pkg.KrediOzetTablo;
                    v_GelirSerisi   Raporlama_Pkg.AylikGelirZamanSerisiTablo;
                    v_KPI           Raporlama_Pkg.AylikKPITablo;
                    v_Funnel        Raporlama_Pkg.FunnelTablo;
                    v_Cohort        Raporlama_Pkg.CohortAnalizTablo;
                BEGIN
                    v_ToplamKredi := Raporlama_Pkg.ToplamKrediListesi;
                    Log_Pkg.LogBilgi('Toplam kredi listesi raporu çalıştırıldı', 'Raporlama_Pkg');

                    v_RiskliMusteri := Raporlama_Pkg.RiskliMusteriler;
                    Log_Pkg.LogBilgi('Riskli müşteri raporu çalıştırıldı', 'Raporlama_Pkg');

                    v_KrediSiralama := Raporlama_Pkg.KrediSiralama;
                    Log_Pkg.LogBilgi('Kredi sıralama raporu çalıştırıldı', 'Raporlama_Pkg');

                    v_RiskAnaliz := Raporlama_Pkg.DetayliRiskAnalizi;
                    Log_Pkg.LogBilgi('Detaylı risk analizi raporu çalıştırıldı', 'Raporlama_Pkg');

                    v_ZamanAnaliz := Raporlama_Pkg.KrediZamanSerisi;
                    Log_Pkg.LogBilgi('Kredi zaman serisi raporu çalıştırıldı', 'Raporlama_Pkg');

                    v_Volatilite := Raporlama_Pkg.KrediVolatiliteAnalizi;
                    Log_Pkg.LogBilgi('Kredi volatilite analizi raporu çalıştırıldı', 'Raporlama_Pkg');

                    v_OzetGS := Raporlama_Pkg.KrediOzet_GroupingSets;
                    Log_Pkg.LogBilgi('Kredi özet raporu (Grouping Sets) çalıştırıldı', 'Raporlama_Pkg');

                    v_OzetRollup := Raporlama_Pkg.KrediOzet_Rollup;
                    Log_Pkg.LogBilgi('Kredi özet raporu (Rollup) çalıştırıldı', 'Raporlama_Pkg');

                    v_OzetCube := Raporlama_Pkg.KrediOzet_Cube;
                    Log_Pkg.LogBilgi('Kredi özet raporu (Cube) çalıştırıldı', 'Raporlama_Pkg');

                    v_GelirSerisi := Raporlama_Pkg.GelirZamanSerisi;
                    Log_Pkg.LogBilgi('Gelir zaman serisi raporu çalıştırıldı', 'Raporlama_Pkg');

                    v_KPI := Raporlama_Pkg.AylikKPIAnalizi;
                    Log_Pkg.LogBilgi('Aylık KPI analizi raporu çalıştırıldı', 'Raporlama_Pkg');

                    v_Funnel := Raporlama_Pkg.KrediFunnelAnalizi;
                    Log_Pkg.LogBilgi('Kredi funnel analizi raporu çalıştırıldı', 'Raporlama_Pkg');

                    v_Cohort := Raporlama_Pkg.MusteriCohortAnalizi;
                    Log_Pkg.LogBilgi('Müşteri cohort analizi raporu çalıştırıldı', 'Raporlama_Pkg');

                END;

            ELSE
                RAISE_APPLICATION_ERROR(-20000, 'Bilinmeyen işlem tipi: '||p_IslemTipi);

        END CASE;
    END TumIslemleriYap;

END QueryBank_Pkg;
/



-- kodları çalıştırma
BEGIN
    
    -- Yeni müşteri açma
    QueryBank_Pkg.TumIslemleriYap('MUSTERI_AC', p_Ad => 'Queenigma', p_Soyad => 'AIBlockNotes', p_TCNo => '12345678905', p_Dogum => DATE '1990-05-10', p_SubeID => 1);

    -- Müşteri pasif etme
    QueryBank_Pkg.TumIslemleriYap('MUSTERI_PASIFET', p_MusteriID => 2004);
    
    -- Hesap açma
    QueryBank_Pkg.TumIslemleriYap('HESAP_AC', p_MusteriID => 30013, p_SubeID => 1, p_KartTuru => 'VADESIZ', p_Tutar => 1000);

    -- Hesap kapatma
    QueryBank_Pkg.TumIslemleriYap('HESAP_KAPAT', p_HesapNo => 4674);

    -- Bakiye güncelleme
    QueryBank_Pkg.TumIslemleriYap('BAKIYE_GUNCELLE', p_HesapNo => 1002, p_Tutar => 500);

    -- Bakiye sorgulama
    QueryBank_Pkg.TumIslemleriYap('BAKIYE_SORGULA', p_HesapNo => 1002);
    
    -- Para yatırma
    QueryBank_Pkg.TumIslemleriYap('PARA_YATIR', p_HesapNo => 1001, p_Tutar => 1500);

    -- Para çekme
    QueryBank_Pkg.TumIslemleriYap('PARA_CEK', p_HesapNo => 1001, p_Tutar => 500);
    
    -- Transfer işlemi
    QueryBank_Pkg.TumIslemleriYap('TRANSFER_YAP', p_HesapNo => 1001, p_HedefHesapNo => 2002, p_Tutar => 1500, p_MusteriID => 3001);

    -- Kart açma
    QueryBank_Pkg.TumIslemleriYap('KART_AC', p_MusteriID => 30013, p_HesapNo => 1001, p_KartTuru => 'KREDI', p_Tutar => 10000, p_SonKullanma => DATE '2028-12-31', p_KartCvc => '123');

    -- Kart işlemi (harcama)
    QueryBank_Pkg.TumIslemleriYap('KART_ISLEM', p_KartNo => 3001, p_Tutar => 250, p_KartIslemTipi => 'HARCA');

    -- Kart bakiye sorgulama
    QueryBank_Pkg.TumIslemleriYap('KART_BAKIYE', p_KartNo => 3001);

    -- Kart kapatma
    QueryBank_Pkg.TumIslemleriYap('KART_KAPAT', p_KartNo => 3001);

    -- Kredi başvurusu
    QueryBank_Pkg.TumIslemleriYap('KREDI_BASVURU', p_MusteriID => 30013, p_Tutar => 50000, p_KartTuru => 'KREDI');

    -- Kredi ödeme
    QueryBank_Pkg.TumIslemleriYap('KREDI_ODEME', p_KrediID => 14028, p_Tutar => 2000);

    -- Swift transfer
    QueryBank_Pkg.TumIslemleriYap('SWIFT_TRANSFER', p_HesapNo => 1001, p_AliciIBAN => 'TR330006100519786457841326', p_Tutar => 10000);

   -- Kur güncelleme işlemi (USD = 43.25TRY)
    QueryBank_Pkg.TumIslemleriYap('KUR_GUNCELLE', p_YeniKur => 43.25);
   
    -- Faiz güncelleme
    QueryBank_Pkg.TumIslemleriYap('FAIZ_GUNCELLE');

    -- Risk kontrol
    QueryBank_Pkg.TumIslemleriYap('RISK_KONTROL', p_MusteriID => 30013);
    
    -- Alarm kapatma işlemi
    QueryBank_Pkg.TumIslemleriYap('ALARM_KAPAT', p_AlarmID => 5001, p_MusteriID => 30013);
    
    -- Kullanıcı ekleme
    QueryBank_Pkg.TumIslemleriYap('KULLANICI_EKLE', p_KullaniciAdi => 'queenig', p_Sifre => '12335', p_Rol => 'ADMIN');

    -- Kullanıcı doğrulama
    QueryBank_Pkg.TumIslemleriYap('KULLANICI_DOGRULA', p_KullaniciAdi => 'queenig', p_Sifre => '12335');

    -- Kullanıcı pasif etme
    QueryBank_Pkg.TumIslemleriYap('KULLANICI_PASIFET', p_KullaniciID => 101);

    -- Raporlama
    QueryBank_Pkg.TumIslemleriYap('RAPORLAMA');
END;
/
