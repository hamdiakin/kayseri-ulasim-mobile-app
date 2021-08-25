import 'package:flutter/material.dart';

class AboutKayseri extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: AppBar(
          title: Text("About Kayseri"),
        ),
        body: Center(
            child: SingleChildScrollView(
              reverse: true,
          child: Column(
            children: [
              Container(
                height: (MediaQuery.of(context).size.height) * 5 / 20,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/kayseri.jpeg'),
                    fit: BoxFit.fitHeight,
                  ),
                ),
              ),
              Container(
                height: (MediaQuery.of(context).size.height) * 12.8 / 20,
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 0),
                    child: Column(
                      children: [
                        Text(
                            "Kayseri, Türkiye'nin kültür, sanat, bilim ve turizm merkezlerinden biri olan Kayseri, tarihin en eski "
                            'zamanlarından beri pek çok uygarlığa beşiklik etmiş ve her dönemde önemini korumuştur. Şehrin en '
                            'eski adı olan Mazaka, Roma devrine kadar devam etmiş; Roma devrinde şehre imparator şehri '
                            'anlamında Kaisareia adı verilmiş; bu isim Araplarca Kaysariya şeklinde kullanılmıştır. Türkler '
                            "Anadolu'yu fethettikten sonra Şehre Kayseriye adını vermişler ve bu ad, Cumhuriyet dönemiyle "
                            'birlikte Kayseri şeklini almıştır. Kayseri, her köşesi değişik uygarlıkların kalıntılarının birbiriyle '
                            "kucaklaştığı Anadolu'nun en köklü ve en eski yerleşim alanlarından biridir. M.Ö. IV.binden, yani "
                            'Kalkolotik (Bakırtaş) çağlardan başlayarak Asur, Hitit, Frig dönemlerinde ve Roma devri sonuna kadar '
                            'bir yerleşim alanı olan Kültepe; bu uygarlıkların kalıntılarını barındıran bir açık hava müzesidir.'
                            'Kayseri, bu önemli merkezin yakınında yer alan bir bölge olarak bu uygarlıkların hepsinden derin izler '
                            "taşımaktadır. 1067'de Selçuklu komutanı Afşin ile Türk hakimiyetine giren Kayseri; Selçuklu Devleti, "
                            'Eratna Beyliği, Dulkadiroğulları, Kadı Burhanettin, Karamanoğulları ve Osmanlı Devleti dönemlerini '
                            'yaşamış, başta Selçuklular olmak üzere her dönemde önemli bir Türk kültür merkezi olmuştur.'
                            'Cumhuriyet döneminde 1924 Anayasası ile il yapılan Kayseri, Ülkemizin ilk uçak fabrikasının kurulması '
                            "ve ardından gelen demiryolları bağlantıları hattı, 1953'te kurulan Sümer Bez Fabrikası ve 1950'lilerde "
                            "başlayan sanayi sitesi ile Türkiye'nin ilk büyük sanayi ve ticaret hamlelerine öncülük etmiştir."
                            'Günümüzde ise Kayseri ekonomik, kültürel, sağlık, eğitim, spor ve şehircilik alanında yakaladığı ivme '
                            "ile Türkiye'nin en hızlı gelişen ve dikkat çeken şehirlerinin başında geliyor. Kayseri, İç Anadolu'nun "
                            'güney bölümü ile Toros Dağlarının birbirine yaklaştığı bir yerde Orta Kızılırmak bölümünde yer alır.37 '
                            'derece 45 dakika ile 38 derece 18 dakika kuzey enlemleri ve 34 derece 56 dakika ile 36 derece 58 '
                            'dakika doğu boylamları arasında bulunmaktadır. Doğu ve kuzeydoğusu Sivas, kuzeyi Yozgat, batısı '
                            'Nevşehir, güneybatısı Niğde, güneyi ise Adana ve Kahramanmaraş İlleri ile çevrilidir. İl yüzölçümü '
                            "16.970 km2 dir. İl yüzölçümünün yüzde 34'ünü tarım arazisi oluşturmaktadır. En düşük arazi oranı ise "
                            'orman ve fundalık alandır. Kayseri orman yönünden oldukça fakirdir. İlin yüzölçümünün ilçeler '
                            'bazında dağılımı aşağıdaki tabloda gösterilmiştir. Kayseri İli nüfusu 2000 yılında 1.060.432 iken, 31 '
                            'Aralık 2015 itibariyle 1.341.056 olmuştur. 2000 yılında nüfus büyüklüğü bakımından son genel nüfus '
                            "sayımına göre ülkemizin 15. büyük ilidir. Nüfus yoğunluğu 79 kişi/km2'dir."),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        )));
  }
}
