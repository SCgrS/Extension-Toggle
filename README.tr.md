# Extension Toggle

[English](README.md)

### [⬇ Windows için indir (ExtensionToggle.exe)](https://github.com/SCgrS/Extension-Toggle/releases/latest/download/ExtensionToggle.exe)

Dosya uzantılarını (.pdf, .docx, .udf gibi) tek çift tıklamayla gösterip gizleyen küçük bir **Windows programı**.

Windows uzantıları varsayılan olarak gizler. Bu ayarı değiştirmek için her seferinde Dosya Gezgini'nin Görünüm menüsüne
girmek gerekir. Extension Toggle aynı ayarı masaüstündeki bir kısayolla açar ya da kapatır, açık klasör pencerelerini ve
masaüstünü yeniler. Pencere açmaz, işini yapıp hemen kapanır.

## Kurulum

Windows 10 ya da Windows 11. Windows'la hazır gelen .NET Framework dışında bir şey gerekmez.

1. Yukarıdaki bağlantıdan `ExtensionToggle.exe` dosyasını indirin ve bilgisayarda kalıcı bir klasöre taşıyın.
2. Dosyaya sağ tıklayıp **Diğer seçenekleri göster › Gönder › Masaüstü (kısayol oluştur)** seçin. Windows 10'da
   **Gönder** doğrudan sağ tık menüsündedir.
3. Kısayola ilk kez çift tıkladığınızda Windows SmartScreen uyarı gösterirse **Daha fazla bilgi**'ye, sonra **Yine de
   çalıştır**'a basın. Uyarı, program imzalı olmadığı için çıkar. Windows 11'de **Akıllı Uygulama Denetimi** açıksa
   Windows imzasız programları hiç çalıştırmaz, program o bilgisayarda açılmaz.

Kurulum programı yoktur, yönetici izni gerekmez. Programı kaynak kodundan derlemek isteyenler için:
[docs/DEVELOPMENT.md](docs/DEVELOPMENT.md) (İngilizce).

## Öne çıkanlar

- **Tek çift tıklama:** Uzantılar gizliyse görünür, görünüyorsa gizlenir.
- **Anında yenileme:** Açık klasör pencereleri ve masaüstü kendiliğinden yenilenir.
- **Pencere açmaz:** Program işini yapıp hemen kapanır.
- **Kurulum gerekmez:** Tek dosyadır, yönetici izni istemez.
- **Tek ayar:** Yalnızca uzantı ayarını değiştirir, başka hiçbir şeye dokunmaz.

## Ne yapar

### Uzantıları gösterme ve gizleme

Masaüstündeki kısayola çift tıklayın. Uzantılar gizliyse görünür, görünüyorsa gizlenir. Açık klasör pencereleri ve
masaüstü kendiliğinden yenilenir. Ayar, Dosya Gezgini'ndeki **Görünüm › Göster › Dosya adı uzantıları** seçeneğinin
aynısıdır (Windows 10'da Görünüm sekmesindeki **Dosya adı uzantıları** kutusu). Biri değişince öbürü de değişir.

Ayar değiştirilemezse program bunu küçük bir uyarı kutusuyla söyler. Programı ve kısayolunu silerseniz uzantılar son
bıraktığınız durumda kalır.

### Nasıl çalışır

Program yalnızca geçerli kullanıcının şu kayıt defteri değerini değiştirir:

```
HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\HideFileExt
```

Uzantılar o an görünüyorsa değer 1, gizliyse 0 yapılır. Sonra açık Dosya Gezgini pencerelerini yeniler ve masaüstüne
yenileme (F5) komutu gönderir.

## Güncelleme

Program kendini güncellemez. Yeni sürüm çıkınca yukarıdaki bağlantıdan indirip eski `ExtensionToggle.exe` dosyasının
yerine koymanız yeter. Masaüstündeki kısayol değişmeden çalışmaya devam eder.

## Veri gizliliği

Program hiçbir veri toplamaz, saklamaz, telemetri içermez ve internete bağlanmaz. Bilgisayara bir şey yüklemez.

## Üçüncü taraf bileşenler

Program hiçbir üçüncü taraf pakete bağlı değildir. Kullandığı her şey Windows'un kendisi ve Windows'la gelen .NET
Framework'tür.

## Otomatik denetimler

[![CodeQL Advanced](https://github.com/SCgrS/Extension-Toggle/actions/workflows/codeql.yml/badge.svg?branch=main)](https://github.com/SCgrS/Extension-Toggle/actions/workflows/codeql.yml)\
[![Dependency Review](https://github.com/SCgrS/Extension-Toggle/actions/workflows/dependency-review.yml/badge.svg?branch=main)](https://github.com/SCgrS/Extension-Toggle/actions/workflows/dependency-review.yml)

---

Soru ve geri bildirimler için: [x.com/CgrShn](https://x.com/CgrShn)

Lisans: AGPL-3.0. Ayrıntılar için [LICENSE](LICENSE) dosyasına bakınız.
