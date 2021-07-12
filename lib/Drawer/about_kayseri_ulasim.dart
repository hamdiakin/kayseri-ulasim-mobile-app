import 'package:flutter/material.dart';

class AboutKayseriUlasim extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: AppBar(
          title: Text("About Kayseri Ulasim"),
        ),
        body: Center(
            child: Column(
          children: [
            Container(
              height: (MediaQuery.of(context).size.height) * 3 / 20,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/kayseri_ulasim_hakkinda.jpg'),
                  fit: BoxFit.fill,
                ),
              ),
            ),
            Container(
              height: (MediaQuery.of(context).size.height) * 10.8 / 20,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 0),
                  child: Column(
                    children: [
                      Text(
                          'Kayseri Ulaşım AŞ, 27.06.2008 tarihinde Kayseri Büyükşehir Belediyesi iştiraki olarak kurulmuştur. 01 Ağustos 2009 tarihinde, yapımı tamamlanan 1. etap raylı sistem hattının geçici kabulü yapılarak, raylı sistem yolcu taşımacılığı faaliyetlerine başlamıştır. 2014 ve 2015 yıllarında 2. ve 3. Etap raylı sistem hatları da tamamlanarak devreye alınmıştır. Kurulduğu günden itibaren “sektöründe öncü kurum olmak” vizyonu ile çalışmalarını yürüten Kayseri Ulaşım AŞ 2011 yılında Türkiye’nin toplu taşımaya bütünleşmiş ilk bisiklet paylaşım sistemi olan KAYBİS’ i Kayseri halkının hizmetine sunmuştur.'
                          'Kayseri Büyükşehir Belediyesi’nin kararları ile 2016 yılında kent içi otobüs işletmeciliği, 2017 yılında kent içi otopark işletmeciliği ve yine 2017 yılında toplu taşımada elektronik ücret toplama sistemi Kayseri Ulaşım AŞ’ye devredilmiştir. Böylelikle kurumun faaliyet alanları genişlemiştir. Bunlarla beraber Kayseri’de fiber optik haberleşme altyapısı Kayseri Ulaşım AŞ tarafından yaptırılmakta ve isteklilere kiralanmaktadır.'
                          'Kayseri Ulaşım AŞ kendi sektöründe birçok alanda Teknoloji AR-GE çalışmaları yapmakta ve proje faaliyetleri yürütmektedir. Bu faaliyetler ile üretilen bilgi, tecrübe ve teknolojiler, kurum ve kamu yararına paylaşılmakta, çalışmalar proje ve nihai ürün haline dönüştürülerek hizmete sunulmaktadır.  Kayseri Ulaşım AŞ, Kasım 2018 de Sanayi ve Teknoloji Bakanlığı’ndan Ar-Ge Merkezi belgesini almıştır.'
                          'Kayseri Ulaşım AŞ, “Mükemmeli aramayı” kurum değerlerinden birisi olarak almaktadır. Bu doğrultuda kurumsal gelişimine yön veren kurum; kalite yönetim sistemi, çevre yönetim sistemi, iş sağlığı ve güvenliği yönetim sistemi, müşteri memnuniyeti yönetim sistemi, enerji yönetim sistemi, bilgi güvenliği yönetim sistemi, Avrupa Birliği toplu taşımacılıkta hizmet kalitesi yönetim sistemi standartlarına uygun olarak faaliyetlerini yürütmektedir.2017 yılında Karbon Saydamlık Projesi’ne (CDP) dahil olan Kayseri Ulaşım AŞ, CDP ‘ye bilimsel temelli hedef taahhüdünde bulunmuştur. '
                          'Bu yönü ile Kayseri Ulaşım AŞ:'
                          'Türkiye’de bilimsel tabanlı hedefi kabul edilen ilk şirkettir.'
                          'Dünya genlinde Ulaşım sektöründe 12 şirketten biridir.'
                          'Türkiye’de tüm sektörlerde 8 şirketten biridir.'
                          'Türkiye’deki tek toplu ulaşım şirketidir.'
                          '2019 yılı verilerine göre; raylı sistem hatlarını kullanan vatandaşlarımız günde ortalama 112.000 yolculuk,  otobüsleri kullanan vatandaşlarımız günde ortalama 252.000 yolculuk yapmıştır. KAYBİS sezonunda bisikletler günde ortalama 4.000 kez kullanılmıştır. Otopark hizmetinden günde ortalama 9.000 kez yararlanılmıştır.'
                          'Kayseri Ulaşım AŞ, günümüzde 34 km uzunluğa sahip raylı sistem hattı,  55 raylı sistem istasyonu, 31 adeti yerli olan 69 raylı sistem aracı, 51 bisiklet istasyonu, 650 bisikleti, özel halk otobüsü ve bölgesel taşıma araçları ile birlikte toplam 957 otobüsü, 7 kapalı otoparkı ve 3882 araçlık park yeri ile Kayseri halkına hizmet etmeye devam etmektedir.'
                          'Yapımı devam eden hatlar tamamlandığında Kayseri Ulaşım AŞ’nin raylı sistem hizmet ağı 48 km’ye çıkacaktır.',
                          style: TextStyle(fontFamily:'Raleway' , fontSize: 15.0,)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        )));
  }
}
