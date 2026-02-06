# QueryBank
Advanced Level SQL Project
Bu proje, Oracle PL/SQL üzerinde geliştirilmiş modüler ve ileri seviye bir bankacılık sistemidir. 
Sistemde her işlev için ayrı paketler (modüller) tasarlayıp, tek bir merkezi paketten QueryBank_Pkg üzerinden yönettim. Böylece tek bir prosedür (TumIslemleriYap) çağrısıyla tüm bankacılık işlemleri yapılabilir hale gelmiş oldu.

- Trigger (Her tabloya yapılan insert/update/delete işlemleri otomatik olarak loglanıyor. Bu sayede sistemde gerçekleşen her olay denetlenebilir hale geliyor.)
- Cursor (Gün sonu faiz işlemleri için cursor kullandım. Cursor ile tüm açık hesaplar tek tek dolaşılıyor ve faiz hesaplaması yapılıyor.)
- Window Functions (ROW_NUMBER, SUM OVER, AVG OVER, STDDEV OVER gibi fonksiyonlarla zaman serisi analizleri, kümülatif toplamlar, son X işlem ortalamaları ve volatilite hesaplamaları yaptım.)
- OLAP Fonksiyonları (Grouping Sets, Rollup, Cube)(Kredi özet raporları farklı boyutlarda alınabiliyor. Çok boyutlu raporlama ve BI raporları için MV view oluşturarak uyguladım.)
- Autonomous Transaction (Log paketinde kullandım. Ana işlem başarısız olsa bile log kaydı silinmiyor.)
- Exception Handling (Her kritik işlemde anlamlı hata mesajları üretiliyor ve log tablosuna kaydediliyor.)
- CTE, subquery gibi ileri seviye yapılar kullandım.
- Ayrıca Cohort, Funnel analizleri, KPI, Volatilite hesaplamaları yaptım

  Modüller ve İşlevleri
- Musteri_Pkg
  Müşteri açma, pasifleştirme, risk skoru hesaplama
- Hesap_Pkg
  Hesap açma, kapatma, bakiye sorgulama/güncelleme
- Islem_Pkg
  Para yatırma, çekme, transfer işlemleri
- Kredi_Pkg 
  Kredi başvurusu, ödeme, durum güncelleme
- Kart_Pkg 
  Kart açma, harcama, bakiye sorgulama, kapatma
- Faiz_Pkg
  Gün sonu faiz işlemleri, faiz oranı güncelleme
- Alarm_Pkg
  Risk kontrolü, alarm ekleme/kapatma
- Swift_Pkg
  Uluslararası transfer (SWIFT), kur güncelleme
- Kullanici_Pkg
  Kullanıcı ekleme, doğrulama, pasifleştirme
- Raporlama_Pkg
  OLAP ve analitik raporlar (Grouping Sets, Rollup, Cube, KPI, Cohort, Funnel)
- Log_Pkg
  Tüm işlemler için otomatik loglama (trigger destekli)
- QueryBank_Pkg
  Merkezi orkestratör tüm modülleri tek prosedürden yönetir

Modüller arasındaki ilişkileri gösteren ER diyagramı
<img width="633" height="392" alt="image" src="https://github.com/user-attachments/assets/480540d6-f7f0-4011-b478-4e4d10715d71" />
