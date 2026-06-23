import 'package:flutter/material.dart';
import '../services/assistant_service.dart';
import '../services/api_service.dart';
class AIChatSheet extends StatefulWidget {
  const AIChatSheet({super.key});

  @override
  State<AIChatSheet> createState() =>
      _AIChatSheetState();
}


class _AIChatSheetState
    extends State<AIChatSheet>
    with SingleTickerProviderStateMixin {

  final TextEditingController controller =
      TextEditingController();

      final ScrollController scrollController =
    ScrollController();

  late AnimationController anim;

  final List<Map<String,dynamic>>
  messages = [];
  String?
  waitingAction;
  String?
  transactionType;
  int? selectedClientId;
String? selectedClientName;
bool amountOnly = false;
  bool showQuickActions = true;

  @override
  void initState() {

    super.initState();

    anim = AnimationController(

      vsync: this,

      duration:

      const Duration(
        seconds: 2,
      ),

    );

    anim.repeat(
      reverse: true,
    );

  }

  @override
  void dispose() {
    scrollController.dispose();

    anim.dispose();

    controller.dispose();

    super.dispose();

  }

Future<void> sendMessage() async {

if(controller.text.trim().isEmpty)
return;

final text = controller.text;
final intent = AssistantService.parse(text);

if (intent["action"] != "unknown") {
  waitingAction = null;
}

controller.clear();
// final detectedIntent =
//     AssistantService.parse(text);
//
// if(detectedIntent["action"] != "unknown"){
//
//   waitingAction = null;
//   transactionType = null;
//
// }

///  أوامر الإلغاء
if(
  text.trim().toLowerCase() == "الغاء" ||
  text.trim().toLowerCase() == "إلغاء" ||
  text.trim().toLowerCase() == "خلاص" ||
  text.trim().toLowerCase() == "cancel"
){
  waitingAction = null;
  transactionType = null;

  setState(() {
    messages.add({
      "text":"✅ تم إلغاء العملية الحالية",
      "user":false,
    });
  });

  return;
}

setState(() {

messages.add({

"text":text,

"user":true,

});

});

if(

waitingAction

==

"add_client"

){

final parts =

text.split(
"-"
);

if(

parts.length>=2

){

try{

await ApiService
.addClient(

name:

parts[0]
.trim(),

phone:

parts[1]
.trim(),

);

setState(() {

messages.add({

"text":

"✅ تم إضافة العميل",

"user":
false,

});

});

waitingAction=
null;

return;

}

catch(_){

setState(() {

messages.add({

"text":

"فشل إضافة العميل",

"user":
false,

});

});

return;

}

}

else{

setState(() {

messages.add({

"text":

"اكتب:\nالاسم - الرقم",

"user":
false,

});

});

return;

}

}
if (waitingAction == "select_client") {

  final clients = await ApiService.getClients();

  print("CLIENTS = $clients");
  print("SEARCH = $text");

  try {

    final client = clients.firstWhere(

      (c) =>
          c["name"]
              .toString()
              .trim()
              .toLowerCase()
              .contains(
                text.trim().toLowerCase(),
              ),

    );

    print("FOUND CLIENT = $client");

    selectedClientId = int.parse(
      client["id"].toString(),
    );

    selectedClientName =
        client["name"].toString();


    if (
    transactionType == "receive" ||
    transactionType == "pay"
) {

  amountOnly = true;

  waitingAction = "transaction";

  setState(() {

    messages.add({

      "text": "اكتب المبلغ فقط",

      "user": false,

    });

  });

}
else {

  amountOnly = false;

  waitingAction = "transaction";

  setState(() {

    messages.add({

      "text":
          "تمام 👌\nاكتب:\nالوصف - المبلغ",

      "user": false,

    });

  });

}

  } catch (e) {

    print("ERROR = $e");

    setState(() {

      messages.add({

        "text":
            "❌ العميل غير موجود\nاكتب اسم عميل صحيح",

        "user": false,

      });

    });

  }

  return;
}
if(

waitingAction

==

"transaction"

){

if (amountOnly) {

  try {

    await ApiService.addTransaction(

      type: transactionType!,

      partyType: "client",

      partyId: selectedClientId,

      title:
          transactionType == "receive"
              ? "استلام"
              : "دفع",

      amount:
          double.parse(text.trim()),

      note: "Added From Assistant",

    );

    setState(() {

      messages.add({

        "text":
            "✅ تم تسجيل العملية",

        "user": false,

      });

    });

    waitingAction = null;
    transactionType = null;
    selectedClientId = null;
    selectedClientName = null;
    amountOnly = false;

    return;

  } catch (_) {

    setState(() {

      messages.add({

        "text":
            "❌ اكتب مبلغ صحيح",

        "user": false,

      });

    });

    return;

  }

}

final parts =
    text.split("-");

if(parts.length>=2){

try{

await ApiService
.addTransaction(

type: transactionType!,

partyType:

"client",

partyId: selectedClientId,

title:

parts[0]
.trim(),

amount:

double.parse(

parts[1]
.trim()

),

note:

"Added From Assistant",

);

setState(() {

messages.add({

"text":

"✅ تم تسجيل العملية",

"user":
false,

});

});

waitingAction = null;
transactionType = null;
selectedClientId = null;
selectedClientName = null;
amountOnly = false;

return;

}

catch(_){

setState(() {

messages.add({

"text":

"فشل العملية",

"user":
false,

});

});

return;

}

}

setState(() {

messages.add({

"text":

"اكتب:\nالوصف - المبلغ",

"user":
false,

});

});

return;

}
final result =

AssistantService
.parse(text);

String reply =
"";

switch(

result["action"]

){

case "add_client":

waitingAction=

"add_client";

reply=

"أضف عميل جديد، اكتب\nاسم العميل - الرقم";

break;

reply =

"هضيف عميل جديد، اكتب:\nاسم العميل - الرقم";

break;

case "sale":

waitingAction = "select_client";

transactionType = "sale";

reply = "مين العميل؟";

break;

case "purchase":

waitingAction = "transaction";

transactionType = "purchase";

reply = "تمام 👍\nاكتب:\nالوصف - المبلغ";

break;

case "receive":

waitingAction = "select_client";

transactionType = "receive";

reply = "مين العميل؟";

break;

case "pay":

waitingAction = "select_client";

transactionType = "pay";

reply = "مين العميل؟";

break;

case "search_client":

try{

final clients =

await ApiService
.getClients();

final query =

text.replaceAll(
"ابحث",
""
).trim();

final result =

clients.where((c)=>

c["name"]

.toString()

.contains(query)

).toList();

if(result.isEmpty){

reply=
"العميل غير موجود";

}else{

reply=

"تم العثور على ${result.length} عميل";

}

}

catch(_){

reply=
"فشل البحث";

}

break;

case "show_clients":

try{

final clients =

await ApiService
.getClients();

if(clients.isEmpty){

reply=
"لا يوجد عملاء";

}else{

reply=

"عدد العملاء: ${clients.length}\n\n";

for(

int i=0;

i<clients.length && i<5;

i++

){

reply +=

"${i+1}- ${clients[i]["name"]}\n";

}

}

}

catch(_){

reply=
"فشل تحميل العملاء";

}

break;

case "balance":

try{

final data=

await ApiService
.getDashboardSummary();

reply=

reply=

reply =

'''
رصيد العملاء:
${data["total_client_balance"]} ج.م

إجمالي المبيعات:
${data["total_sales"]}

إجمالي المشتريات:
${data["total_purchases"]}

عدد العملاء:
${data["total_clients"]}
''';

}

catch(_){

reply=
"فشل تحميل الرصيد";

}

break;

case "sales":

  try {

    final data =
        await ApiService.getDashboardSummary();

    reply = '''
إجمالي المبيعات:
${data["total_sales"]} ج.م

مبيعات اليوم:
${data["today_sales"]} ج.م
''';

  } catch (_) {

    reply = "فشل تحميل المبيعات";

  }

  break;
case "notifications":

try{

final list=

await ApiService
.getNotifications();

reply=

"عندك ${list.length} إشعار";

}

catch(_){

reply=
"فشل تحميل الإشعارات";

}

break;

default:

reply = '''
يمكنني مساعدتك في:

• العملاء
• الرصيد
• المبيعات
• الإشعارات
• إضافة عميل
• تسجيل عملية

اكتب سؤالك بطريقة أخرى.
''';

}

setState(() {

messages.add({

"text":

reply,

"user":

false,

});

});

}
Widget _quickChip(String text) {

  return GestureDetector(

    onTap: () {

  setState(() {

    showQuickActions = false;

  });

  controller.text = text;

  sendMessage();

},

    child: Container(

   padding: const EdgeInsets.symmetric(
  horizontal: 14,
  vertical: 10,
),
      decoration: BoxDecoration(

        color: const Color(0xFF0F1B3D),

        borderRadius:
            BorderRadius.circular(18),

        border: Border.all(
          color: Colors.cyan.withOpacity(.3),
        ),

      ),

      child: Text(

        text,

        style: const TextStyle(
          color: Colors.white,
        ),

      ),

    ),

  );

}

  @override
  Widget build(
      BuildContext context){

    return Scaffold(
    resizeToAvoidBottomInset: true,

      backgroundColor: const Color(0xFF0D0D0D),

      appBar:

      AppBar(

        backgroundColor: const Color(0xFF0D0D0D),

        elevation:0,

        leading:

        IconButton(

          icon:

          const Icon(

            Icons.arrow_back_ios,

            color:
            Colors.white,

          ),

          onPressed:(){

            Navigator.pop(
                context);

          },

        ),

        centerTitle:true,

       title: const Text(
  "Cash Flow AI",
  style: TextStyle(
    color: Colors.white,
    fontSize: 22,

            fontWeight:
            FontWeight.w600,

          ),

        ),

        actions:[

          IconButton(

            onPressed:(){

              Navigator.pop(
                  context);

            },

            icon:

            const Icon(

              Icons.close,

              color:
              Colors.white,

            ),

          )

        ],

      ),

      body:

      Column(

        children:[

          const SizedBox(
              height:15),

    if(messages.isEmpty)
const Padding(
  padding: EdgeInsets.only(
    top: 30,
    bottom: 15,
  ),
  child: Text(
    "What can I help with today?",
    style: TextStyle(
      color: Colors.white,
      fontSize: 26,
      fontWeight: FontWeight.w500,
    ),
    textAlign: TextAlign.center,
  ),
),      




          Expanded(

            child:

            ListView.builder(
            controller: scrollController,

              padding:

              const EdgeInsets.all(
                  20),

              itemCount:
              messages.length,

              itemBuilder:

                  (_,index){

                final msg =
                messages[index];

                return Align(

                  alignment:

                  msg["user"]

                      ?

                  Alignment
                      .centerRight

                      :

                  Alignment
                      .centerLeft,

                  child:

                  Container(

                    margin:

                    const EdgeInsets
                        .only(
                        bottom:12),

                    padding:

                    const EdgeInsets
                        .all(14),

                    decoration:

                    BoxDecoration(

                      color:

                      msg["user"]

                          ?

                      const Color(0xFF00C8FF)

                          :

                      const Color(
                          0xff111111),

                      borderRadius:

                      BorderRadius
                          .circular(
                          18),

                    ),

                    child:

                    Text(

                      msg["text"],

                      style:

                      TextStyle(

                        color:

                        msg["user"]

                            ?

                        Colors.black

                            :

                        Colors.white,

                      ),

                    ),

                  ),

                );

              },

            ),

          ),

          SafeArea(

            child:

            Padding(

              padding:

              const EdgeInsets
                  .all(18),

              child:

              Container(

                padding:

                const EdgeInsets
                    .only(

                  left:20,

                  right:8,

                  top:8,

                  bottom:8,

                ),

                decoration:

                BoxDecoration(

                  color:
                  Colors.black,

                  border:

                  Border.all(

                    color:
                    Colors.white12,

                  ),

                  borderRadius:

                  BorderRadius.circular(
                      40),

                ),

                child:

                Row(

                  children:[

                    Expanded(

                      child:

                      TextField(
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) {
  sendMessage();
},


                        controller:
                        controller,
                        onTap: () {

  if(showQuickActions){

    setState(() {

      showQuickActions = false;

    });

  }

},

                        style:

                        const TextStyle(

                          color:
                          Colors.white,

                        ),

                        decoration:

                        const InputDecoration(

                          hintText:

                          "اسأل AI",

                          hintStyle:

                          TextStyle(

                            color:
                            Colors.white38,

                          ),

                          border:
                          InputBorder.none,

                        ),

                      ),

                    ),

                    Container(

                      height:65,

                      width:65,

                      decoration:

                      BoxDecoration(

                        shape:
                        BoxShape.circle,

                        color:
                        Colors.cyan,

                        boxShadow:[

                          BoxShadow(

                            color:
                            Colors.cyan,

                            blurRadius:
                            25,

                          )

                        ],

                      ),

                      child:

                      IconButton(

                        onPressed: () {

sendMessage();

},

                        icon:

                        const Icon(

                          Icons.send,

                          color:
                          Colors.black,

                          size:30,

                        ),

                      ),

                    )

                  ],

                ),

              ),

            ),

          )

        ],

      ),

    );

  }

}
