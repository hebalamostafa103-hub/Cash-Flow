class AssistantService {

  static Map<String, dynamic> parse(String text) {

    text = text.toLowerCase().trim();

    // ======================
    // ADD CLIENT
    // ======================
    if (
      text.contains("اضف عميل") ||
      text.contains("ضيف عميل") ||
      text.contains("عميل جديد") ||
      text.contains("انشاء عميل") ||
      text.contains("اعمل عميل") ||
      text.contains("سجل عميل")
    ) {
      return {"action": "add_client"};
    }
    // ======================
    // SALES REPORT
    // ======================
    if (
      text.contains("المبيعات") ||
      text.contains("مبيعات") ||
      text.contains("اجمالي المبيعات") ||
      text.contains("كم بعت") ||
      text.contains("بعت كام") ||
      text.contains("بعت قد ايه") ||
      text.contains("المبيعات كام") ||
      text.contains("كام مبيعات")
    ) {
      return {"action": "sales"};
    }

    // ======================
    // SALE
    // ======================
    if (
      text.contains("عملية بيع") ||
      text.contains("عمليه بيع") ||
      text.contains("ضيف عملية بيع") ||
      text.contains("ضيف عمليه بيع") ||
      text.contains("بيع") ||
      text.contains("بعت")
    ) {
      return {"action": "sale"};
    }

    // ======================
    // PURCHASE
    // ======================
    if (
      text.contains("عملية شراء") ||
      text.contains("عمليه شراء") ||
      text.contains("ضيف عملية شراء") ||
      text.contains("ضيف عمليه شراء") ||
      text.contains("شراء") ||
      text.contains("اشتريت")
    ) {
      return {"action": "purchase"};
    }

    // ======================
    // RECEIVE MONEY
    // ======================
    if (
      text.contains("استلام") ||
      text.contains("استلمت") ||
      text.contains("قبض") ||
      text.contains("قبضت") ||
      text.contains("تحصيل") ||
      text.contains("ايراد") ||
      text.contains("وارد")
    ) {
      return {"action": "receive"};
    }

    // ======================
    // PAY MONEY
    // ======================
    if (
      text.contains("دفع") ||
      text.contains("دفعت") ||
      text.contains("سداد") ||
      text.contains("مصروف") ||
      text.contains("صرف") ||
      text.contains("خسارة") ||
      text.contains("خساره")
    ) {
      return {"action": "pay"};
    }

    

    // ======================
    // BALANCE
    // ======================
    if (
      text.contains("رصيد") ||
      text.contains("الرصيد") ||
      text.contains("فلوسى") ||
      text.contains("حسابى") ||
      text.contains("معايا كام") ||
      text.contains("الرصيد كام") ||
      text.contains("التقرير") ||
      text.contains("احصائيات")
    ) {
      return {"action": "balance"};
    }

    // ======================
    // NOTIFICATIONS
    // ======================
    if (
      text.contains("اشعار") ||
      text.contains("اشعارات") ||
      text.contains("تنبيه") ||
      text.contains("تنبيهات") ||
      text.contains("الاخطارات")
    ) {
      return {"action": "notifications"};
    }

    // ======================
    // SEARCH CLIENT
    // ======================
    if (
      text.contains("ابحث") ||
      text.contains("ابحث عن") ||
      text.contains("دور") ||
      text.contains("دور على") ||
      text.contains("فين العميل")
    ) {
      return {"action": "search_client"};
    }

    // ======================
    // SHOW CLIENTS
    // ======================
    if (
      text.contains("العملاء") ||
      text.contains("عملاء") ||
      text.contains("قائمة العملاء") ||
      text.contains("اعرض العملاء") ||
      text.contains("هات العملاء") ||
      text.contains("كم عميل") ||
      text.contains("كام عميل")
    ) {
      return {"action": "show_clients"};
    }

    return {"action": "unknown"};
  }
}