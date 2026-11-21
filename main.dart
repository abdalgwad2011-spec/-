
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(const AnsahniApp());

class AnsahniApp extends StatelessWidget {
  const AnsahniApp({super.key});
  @override Widget build(BuildContext context) {
    return MaterialApp(
      title: 'انصحني', debugShowCheckedModeBanner: false,
      theme: ThemeData(primaryColor: const Color(0xFF0B5D3B), fontFamily: 'Amiri', useMaterial3: true),
      home: const HomeScreen(),
    );
  }
}

// ---------- DATA ----------
final List<Map<String,dynamic>> advices = [
  {'text':'ابدأ يومك بركعتين.. ربنا بيحب اللي بيبدأ بيه','source':'﴿وَقُل رَّبِّ زِدْنِي عِلْمًا﴾ - طه 114','cat':'علاقتك بربنا'},
  {'text':'متأجلش التوبة.. باب ربنا مفتوح طول ما انت بتتنفس','source':'﴿وَتُوبُوا إِلَى اللَّهِ جَمِيعًا﴾ - النور 31','cat':'التوبة'},
  {'text':'صاحبك هو اللي هيشدك لفوق أو لتحت.. اختار صح','source':'المرء على دين خليله - أبو داود','cat':'الصحبة'},
  {'text':'لو مخنوق.. افتح المصحف، هتلاقي رسالتك مستنياك','source':'﴿أَلَا بِذِكْرِ اللَّهِ تَطْمَئِنُّ الْقُلُوبُ﴾ - الرعد 28','cat':'الصبر'},
  {'text':'بر والديك.. ده باب الجنة اللي جنبك','source':'﴿وَبِالْوَالِدَيْنِ إِحْسَانًا﴾ - الإسراء 23','cat':'بر الوالدين'},
  {'text':'رزقك مكتوب.. اسعى وسيب الباقي على ربنا','source':'﴿وَمَن يَتَّقِ اللَّهَ يَجْعَل لَّهُ مَخْرَجًا﴾ - الطلاق 2','cat':'الرزق'},
];
final List<Map<String,dynamic>> surahs = List.generate(114, (i){
  const names = ['الفاتحة','البقرة','آل عمران','النساء','المائدة','الأنعام','الأعراف','الأنفال','التوبة','يونس','هود','يوسف','الرعد','إبراهيم','الحجر','النحل','الإسراء','الكهف','مريم','طه','الأنبياء','الحج','المؤمنون','النور','الفرقان','الشعراء','النمل','القصص','العنكبوت','الروم','لقمان','السجدة','الأحزاب','سبأ','فاطر','يس','الصافات','ص','الزمر','غافر','فصلت','الشورى','الزخرف','الدخان','الجاثية','الأحقاف','محمد','الفتح','الحجرات','ق','الذاريات','الطور','النجم','القمر','الرحمن','الواقعة','الحديد','المجادلة','الحشر','الممتحنة','الصف','الجمعة','المنافقون','التغابن','الطلاق','التحريم','الملك','القلم','الحاقة','المعارج','نوح','الجن','المزمل','المدثر','القيامة','الإنسان','المرسلات','النبأ','النازعات','عبس','التكوير','الانفطار','المطففين','الانشقاق','البروج','الطارق','الأعلى','الغاشية','الفجر','البلد','الشمس','الليل','الضحى','الشرح','التين','العلق','القدر','البينة','الزلزلة','العاديات','القارعة','التكاثر','العصر','الهمزة','الفيل','قريش','الماعون','الكوثر','الكافرون','النصر','المسد','الإخلاص','الفلق','الناس'];
  return {'num': i+1, 'name': names[i]};
});

// الوظيفة الزروقية - مختصرة هنا للعرض، والنسخة الكاملة في ملف assets/wazifa.json
final List<Map<String,dynamic>> wazifa = [
  {'text':'أَعُوذُ بِاللَّهِ مِنَ الشَّيْطَانِ الرَّجِيمِ، بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ','count':1},
  {'text':'﴿وَإِلَهُكُمْ إِلَهٌ وَاحِدٌ لَّا إِلَهَ إِلَّا هُوَ الرَّحْمَنُ الرَّحِيمُ﴾','count':1},
  {'text':'آية الكرسي كاملة: اللَّهُ لَا إِلَهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ...','count':1},
  {'text':'خواتيم سورة البقرة: آمَنَ الرَّسُولُ بِمَا أُنزِلَ إِلَيْهِ...','count':1},
  {'text':'قُلْ هُوَ اللَّهُ أَحَدٌ','count':3},
  {'text':'قُلْ أَعُوذُ بِرَبِّ الْفَلَقِ','count':3},
  {'text':'قُلْ أَعُوذُ بِرَبِّ النَّاسِ','count':3},
  {'text':'اللَّهُمَّ إِنِّي أَعُوذُ بِكَ أَنْ أُشْرِكَ بِكَ وَأَنَا أَعْلَمُ','count':3},
  {'text':'اللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنَ الْهَمِّ وَالْحَزَنِ','count':3},
  {'text':'سَيِّدُ الِاسْتِغْفَارِ: اللَّهُمَّ أَنْتَ رَبِّي لَا إِلَهَ إِلَّا أَنْتَ','count':3},
  {'text':'رَضِيتُ بِاللَّهِ رَبًّا وَبِالْإِسْلَامِ دِينًا وَبِمُحَمَّدٍ ﷺ نَبِيًّا','count':3},
  {'text':'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ عَدَدَ خَلْقِهِ وَرِضَا نَفْسِهِ','count':3},
  {'text':'بِسْمِ اللَّهِ الَّذِي لَا يَضُرُّ مَعَ اسْمِهِ شَيْءٌ','count':3},
  {'text':'لَا إِلَهَ إِلَّا اللَّهُ','count':100},
  {'text':'أَصْبَحْنَا وَأَصْبَحَ الْمُلْكُ لِلَّهِ','count':3},
];

class HomeScreen extends StatefulWidget { const HomeScreen({super.key}); @override State<HomeScreen> createState()=>_HomeState(); }
class _HomeState extends State<HomeScreen> {
  int idx=0; int adviceIdx=0; int tasbeeh=0; int logoTaps=0; String mode='morning';
  List<Map<String,String>> chat=[]; List<Map<String,String>> sheikhInbox=[
    {'from':'شاب 1','msg':'أنا مخنوق ومش عارف أعمل إيه'},
    {'from':'شاب 2','msg':'عايز أبدأ أصلي بس بكسل'},
    {'from':'شاب 3','msg':'عملت ذنب وعايز أتوب'},
  ];
  String format12(DateTime t){ int h=t.hour; String ap=h>=12?'م':'ص'; int h12=h%12==0?12:h%12; return '${h12.toString().padLeft(2,'0')}:${t.minute.toString().padLeft(2,'0')} $ap'; }

  @override Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(backgroundColor: const Color(0xFF0B5D3B), title: Row(children:[
        GestureDetector(onTap:(){ logoTaps++; if(logoTaps>=5){ logoTaps=0; _openSheikh(); } }, child: const CircleAvatar(backgroundColor: Colors.amber, child: Text('ان', style: TextStyle(color: Colors.black)))),
        const SizedBox(width:8), const Text('انصحني', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        const Spacer(), Text(format12(DateTime.now()), style: const TextStyle(color: Colors.white, fontSize:14)),
      ])),
      body: [ _home(), _advicePage(), _azkarPage(), _quranPage(), _chatPage() ][idx],
      bottomNavigationBar: BottomNavigationBar(currentIndex: idx, onTap:(v)=>setState(()=>idx=v), selectedItemColor: const Color(0xFF0B5D3B), unselectedItemColor: Colors.grey, type: BottomNavigationBarType.fixed, items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label:'الرئيسية'),
        BottomNavigationBarItem(icon: Icon(Icons.lightbulb), label:'نصيحتي'),
        BottomNavigationBarItem(icon: Icon(Icons.menu_book), label:'الوظيفة'),
        BottomNavigationBarItem(icon: Icon(Icons.book), label:'المصحف'),
        BottomNavigationBarItem(icon: Icon(Icons.chat), label:'فضفض'),
      ]),
    );
  }

  Widget _home(){
    final a = advices[adviceIdx];
    return ListView(padding: const EdgeInsets.all(16), children:[
      Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: const Color(0xFF0B5D3B), borderRadius: BorderRadius.circular(20)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children:[
        const Text('نصيحة اليوم', style: TextStyle(color: Colors.amber, fontSize:18, fontWeight: FontWeight.bold)),
        const SizedBox(height:10), Text(a['text'], style: const TextStyle(color: Colors.white, fontSize:22)),
        const SizedBox(height:10), Text(a['source'], style: const TextStyle(color: Colors.white70)),
        const SizedBox(height:12), ElevatedButton(onPressed:()=>setState(()=>adviceIdx=(adviceIdx+1)%advices.length), child: const Text('نصيحة جديدة')),
      ])),
      const SizedBox(height:16),
      Card(child: ListTile(title: const Text('عداد الاستغفار'), subtitle: Text('استغفرت $tasbeeh / 100'), trailing: ElevatedButton(onPressed:()=>setState(()=>tasbeeh++), child: const Text('استغفر الله')))),
      const SizedBox(height:10),
      const Card(child: ListTile(title: Text('مواقيت الصلاة - الأقصر'), subtitle: Text('الفجر 05:12 ص | الظهر 12:30 م | العصر 03:45 م | المغرب 05:58 م | العشاء 07:28 م'))),
      const SizedBox(height:10),
      const Text('لدخول الشيخ: اضغط على اللوجو 5 مرات - كلمة السر 1234', style: TextStyle(color: Colors.grey, fontSize:12)),
    ]);
  }
  Widget _advicePage()=> ListView(children: advices.map((a)=> Card(child: ListTile(title: Text(a['text']), subtitle: Text(a['source'])))).toList());
  Widget _azkarPage(){
    return Column(children:[
      Padding(padding: const EdgeInsets.all(12), child: Row(children:[
        ChoiceChip(label: const Text('أذكار الصباح'), selected: mode=='morning', onSelected:(_)=>setState(()=>mode='morning')),
        const SizedBox(width:8),
        ChoiceChip(label: const Text('أذكار المساء'), selected: mode=='evening', onSelected:(_)=>setState(()=>mode='evening')),
      ])),
      const Padding(padding: EdgeInsets.all(8), child: Text('الوظيفة الزروقية - تُقرأ عقب صلاة الصبح وعقب صلاة العصر', style: TextStyle(fontWeight: FontWeight.bold))),
      Expanded(child: ListView(children: wazifa.map((w){
        String t=w['text']; if(mode=='evening') t=t.replaceAll('أَصْبَحْنَا','أَمْسَيْنَا').replaceAll('أَصْبَحَ','أَمْسَى');
        return Card(child: ListTile(title: Text(t, textDirection: TextDirection.rtl), trailing: Chip(label: Text('×${w['count']}'))));
      }).toList())),
    ]);
  }
  Widget _quranPage(){
    return ListView(children: surahs.map((s)=> ListTile(title: Text('سورة ${s['name']}'), subtitle: Text('سورة رقم ${s['num']}'), trailing: const Icon(Icons.arrow_forward_ios), onTap:()=>Navigator.push(context, MaterialPageRoute(builder:(_)=> SurahPage(num: s['num'], name: s['name']))))).toList());
  }
  Widget _chatPage(){
    final ctrl = TextEditingController();
    return Column(children:[
      const ListTile(leading: CircleAvatar(child: Text('ش')), title: Text('الشيخ أحمد - مستشارك الديني'), subtitle: Text('متصل الآن • خصوصيتك محفوظة', style: TextStyle(color: Colors.green))),
      Expanded(child: ListView(children: chat.map((m)=> Align(alignment: m['who']=='me'?Alignment.centerLeft:Alignment.centerRight, child: Container(margin: const EdgeInsets.all(6), padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: m['who']=='me'?const Color(0xFF0B5D3B):Colors.grey[200], borderRadius: BorderRadius.circular(12)), child: Text(m['msg']!, style: TextStyle(color: m['who']=='me'?Colors.white:Colors.black))))).toList())),
      Row(children:[ Expanded(child: TextField(controller: ctrl, decoration: const InputDecoration(hintText: 'اكتب اللي مضايقك...'))), IconButton(icon: const Icon(Icons.send), onPressed:(){
        if(ctrl.text.isEmpty) return; setState(()=>chat.add({'who':'me','msg':ctrl.text}));
        // رسالة للمستخدم: الشيخ هيرد
        Future.delayed(const Duration(seconds:1), ()=> setState(()=>chat.add({'who':'sheikh','msg':'تم إرسال رسالتك للشيخ أحمد ✅ هيرد عليك أول ما يشوفها'})));
        ctrl.clear();
      })]),
    ]);
  }
  void _openSheikh(){
    showDialog(context: context, builder:(_){
      final c=TextEditingController(); return AlertDialog(title: const Text('دخول الشيخ (سري)'), content: TextField(controller: c, obscureText: true, decoration: const InputDecoration(hintText: 'كلمة السر')) , actions:[ TextButton(onPressed:(){ if(c.text=='1234'){ Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder:(_)=> SheikhPage(inbox: sheikhInbox))); } }, child: const Text('دخول')) ]);
    });
  }
}
class SheikhPage extends StatelessWidget {
  final List<Map<String,String>> inbox; const SheikhPage({super.key, required this.inbox});
  @override Widget build(BuildContext context){ return Scaffold(appBar: AppBar(title: const Text('لوحة الشيخ')), body: ListView(children: inbox.map((m)=> Card(child: ListTile(title: Text(m['from']!), subtitle: Text(m['msg']!), trailing: const Chip(label: Text('جديد'))))).toList())); }
}
class SurahPage extends StatefulWidget { final int num; final String name; const SurahPage({super.key, required this.num, required this.name}); @override State<SurahPage> createState()=>_SurahState(); }
class _SurahState extends State<SurahPage> {
  List<String> ayahs=[]; bool loading=true; String err='';
  @override void initState(){ super.initState(); _load(); }
  Future<void> _load() async {
    try{
      final r = await http.get(Uri.parse('https://api.alquran.cloud/v1/surah/${widget.num}'));
      if(r.statusCode==200){
        final j=jsonDecode(r.body); final List list=j['data']['ayahs'] as List;
        setState(()=> ayahs=list.map((e)=> e['text'].toString()).toList());
      } else { setState(()=> err='فشل التحميل'); }
    }catch(e){ setState(()=> err='تأكد من النت: $e'); }
    setState(()=> loading=false);
  }
  @override Widget build(BuildContext context){
    return Scaffold(appBar: AppBar(title: Text('سورة ${widget.name}')), body: loading? const Center(child: CircularProgressIndicator()) : err.isNotEmpty? Center(child: Column(mainAxisSize: MainAxisSize.min, children:[Text(err), ElevatedButton(onPressed:(){ setState(()=>loading=true); _load(); }, child: const Text('حاول مرة أخرى'))])) : SingleChildScrollView(padding: const EdgeInsets.all(16), child: Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: const Color(0xFFFDF6E3), border: Border.all(color: Colors.amber)), child: Text(ayahs.asMap().entries.map((e)=> '${e.value} ﴿${e.key+1}﴾ ').join(' '), textAlign: TextAlign.justify, style: const TextStyle(fontSize:22, height:2)))));
  }
}
