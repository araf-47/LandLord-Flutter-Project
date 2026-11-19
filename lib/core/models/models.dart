class Property {
  final String id;
  final String name;
  final String address;
  final String district;
  final String area;
  final String propertyType;
  final int landlordId;
  final int createdAt;

  Property({
    required this.id,
    required this.name,
    required this.address,
    required this.district,
    required this.area,
    required this.propertyType,
    required this.landlordId,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
    'local_id': id,
    'name': name,
    'address': address,
    'district': district,
    'area': area,
    'property_type': propertyType,
    'landlord_id': landlordId,
    'created_at': createdAt,
  };

  factory Property.fromMap(Map<String, dynamic> map) => Property(
    id: map['local_id'] as String,
    name: map['name'] as String,
    address: map['address'] as String,
    district: map['district'] as String,
    area: map['area'] as String,
    propertyType: map['property_type'] as String? ?? 'apartment',
    landlordId: map['landlord_id'] as int? ?? 101,
    createdAt: map['created_at'] as int? ?? 0,
  );
}

class PropertyUnit {
  final String id;
  final String propertyId;
  final String unitNumber;
  final double rent;
  final String status; // 'occupied', 'vacant'
  final String propertyType;
  final bool adPaused;
  final String utilityItemsJson;
  final int createdAt;

  PropertyUnit({
    required this.id,
    required this.propertyId,
    required this.unitNumber,
    required this.rent,
    required this.status,
    required this.propertyType,
    required this.adPaused,
    required this.utilityItemsJson,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
    'local_id': id,
    'property_id': propertyId,
    'unit_number': unitNumber,
    'rent': rent,
    'status': status,
    'property_type': propertyType,
    'ad_paused': adPaused ? 1 : 0,
    'utility_items_json': utilityItemsJson,
    'created_at': createdAt,
  };

  factory PropertyUnit.fromMap(Map<String, dynamic> map) => PropertyUnit(
    id: map['local_id'] as String,
    propertyId: map['property_id'] as String,
    unitNumber: map['unit_number'] as String,
    rent: (map['rent'] as num).toDouble(),
    status: map['status'] as String? ?? 'vacant',
    propertyType: map['property_type'] as String? ?? 'apartment',
    adPaused: (map['ad_paused'] as int? ?? 0) == 1,
    utilityItemsJson: map['utility_items_json'] as String? ?? '[]',
    createdAt: map['created_at'] as int? ?? 0,
  );
}

class Tenant {
  final String id;
  final String name;
  final String phone;
  final String email;
  final String nationalId;
  final String unitId;
  final String status;
  final int createdAt;

  Tenant({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.nationalId,
    required this.unitId,
    required this.status,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
    'local_id': id,
    'name': name,
    'phone': phone,
    'email': email,
    'national_id': nationalId,
    'unit_id': unitId,
    'status': status,
    'created_at': createdAt,
  };

  factory Tenant.fromMap(Map<String, dynamic> map) => Tenant(
    id: map['local_id'] as String,
    name: map['name'] as String,
    phone: map['phone'] as String,
    email: map['email'] as String,
    nationalId: map['national_id'] as String,
    unitId: map['unit_id'] as String,
    status: map['status'] as String? ?? 'active',
    createdAt: map['created_at'] as int? ?? 0,
  );
}

class RentalAgreement {
  final String id;
  final String tenantId;
  final String unitId;
  final String startDate;
  final String terms;
  final double deposit;
  final int createdAt;

  RentalAgreement({
    required this.id,
    required this.tenantId,
    required this.unitId,
    required this.startDate,
    required this.terms,
    required this.deposit,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
    'local_id': id,
    'tenant_id': tenantId,
    'unit_id': unitId,
    'start_date': startDate,
    'terms': terms,
    'deposit': deposit,
    'created_at': createdAt,
  };

  factory RentalAgreement.fromMap(Map<String, dynamic> map) => RentalAgreement(
    id: map['local_id'] as String,
    tenantId: map['tenant_id'] as String,
    unitId: map['unit_id'] as String,
    startDate: map['start_date'] as String,
    terms: map['terms'] as String,
    deposit: (map['deposit'] as num).toDouble(),
    createdAt: map['created_at'] as int? ?? 0,
  );
}

class Invoice {
  final String id;
  final String tenantId;
  final String unitId;
  final String period;
  final double rent;
  final double utilityTotal;
  final double prevUnpaidRolled;
  final double amount;
  final double balance;
  final String status; // 'paid', 'partial', 'unpaid'
  final String dueDate;
  final int createdAt;

  Invoice({
    required this.id,
    required this.tenantId,
    required this.unitId,
    required this.period,
    required this.rent,
    required this.utilityTotal,
    required this.prevUnpaidRolled,
    required this.amount,
    required this.balance,
    required this.status,
    required this.dueDate,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
    'local_id': id,
    'tenant_id': tenantId,
    'unit_id': unitId,
    'period': period,
    'rent': rent,
    'utility_total': utilityTotal,
    'prev_unpaid_rolled': prevUnpaidRolled,
    'amount': amount,
    'balance': balance,
    'status': status,
    'due_date': dueDate,
    'created_at': createdAt,
  };

  factory Invoice.fromMap(Map<String, dynamic> map) => Invoice(
    id: map['local_id'] as String,
    tenantId: map['tenant_id'] as String,
    unitId: map['unit_id'] as String,
    period: map['period'] as String,
    rent: (map['rent'] as num).toDouble(),
    utilityTotal: (map['utility_total'] as num).toDouble(),
    prevUnpaidRolled: (map['prev_unpaid_rolled'] as num).toDouble(),
    amount: (map['amount'] as num).toDouble(),
    balance: (map['balance'] as num).toDouble(),
    status: map['status'] as String? ?? 'unpaid',
    dueDate: map['due_date'] as String,
    createdAt: map['created_at'] as int? ?? 0,
  );
}

class Payment {
  final String id;
  final String tenantId;
  final String invoiceId;
  final double amount;
  final String method; // 'cash', 'bank', 'mobile'
  final String status; // 'confirmed'
  final String date;
  final String transactionRef;
  final int createdAt;

  Payment({
    required this.id,
    required this.tenantId,
    required this.invoiceId,
    required this.amount,
    required this.method,
    required this.status,
    required this.date,
    required this.transactionRef,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
    'local_id': id,
    'tenant_id': tenantId,
    'invoice_id': invoiceId,
    'amount': amount,
    'method': method,
    'status': status,
    'date': date,
    'transaction_ref': transactionRef,
    'created_at': createdAt,
  };

  factory Payment.fromMap(Map<String, dynamic> map) => Payment(
    id: map['local_id'] as String,
    tenantId: map['tenant_id'] as String,
    invoiceId: map['invoice_id'] as String,
    amount: (map['amount'] as num).toDouble(),
    method: map['method'] as String,
    status: map['status'] as String? ?? 'confirmed',
    date: map['date'] as String,
    transactionRef: map['transaction_ref'] as String,
    createdAt: map['created_at'] as int? ?? 0,
  );
}

class Expense {
  final String id;
  final String propertyId;
  final String category; // 'Maintenance', 'Utility', 'Cleaning'
  final String description;
  final double amount;
  final String bearer; // 'landlord', 'tenant'
  final String? tenantId;
  final String date;
  final int createdAt;

  Expense({
    required this.id,
    required this.propertyId,
    required this.category,
    required this.description,
    required this.amount,
    required this.bearer,
    this.tenantId,
    required this.date,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
    'local_id': id,
    'property_id': propertyId,
    'category': category,
    'description': description,
    'amount': amount,
    'bearer': bearer,
    'tenant_id': tenantId,
    'date': date,
    'created_at': createdAt,
  };

  factory Expense.fromMap(Map<String, dynamic> map) => Expense(
    id: map['local_id'] as String,
    propertyId: map['property_id'] as String,
    category: map['category'] as String,
    description: map['description'] as String,
    amount: (map['amount'] as num).toDouble(),
    bearer: map['bearer'] as String,
    tenantId: map['tenant_id'] as String?,
    date: map['date'] as String,
    createdAt: map['created_at'] as int? ?? 0,
  );
}

class MaintenanceTicket {
  final String id;
  final String unitId;
  final String tenantId;
  final String title;
  final String description;
  final String status; // 'pending', 'in_progress', 'resolved'
  final String priority; // 'low', 'medium', 'high'
  final int createdAt;

  MaintenanceTicket({
    required this.id,
    required this.unitId,
    required this.tenantId,
    required this.title,
    required this.description,
    required this.status,
    required this.priority,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
    'local_id': id,
    'unit_id': unitId,
    'tenant_id': tenantId,
    'title': title,
    'description': description,
    'status': status,
    'priority': priority,
    'created_at': createdAt,
  };

  factory MaintenanceTicket.fromMap(Map<String, dynamic> map) => MaintenanceTicket(
    id: map['local_id'] as String,
    unitId: map['unit_id'] as String,
    tenantId: map['tenant_id'] as String,
    title: map['title'] as String,
    description: map['description'] as String,
    status: map['status'] as String? ?? 'pending',
    priority: map['priority'] as String? ?? 'medium',
    createdAt: map['created_at'] as int? ?? 0,
  );
}

class MarketplaceRequest {
  final String id;
  final String unitId;
  final String applicantName;
  final String applicantPhone;
  final String message;
  final String status; // 'pending', 'approved', 'rejected'
  final int createdAt;

  MarketplaceRequest({
    required this.id,
    required this.unitId,
    required this.applicantName,
    required this.applicantPhone,
    required this.message,
    required this.status,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
    'local_id': id,
    'unit_id': unitId,
    'applicant_name': applicantName,
    'applicant_phone': applicantPhone,
    'message': message,
    'status': status,
    'created_at': createdAt,
  };

  factory MarketplaceRequest.fromMap(Map<String, dynamic> map) => MarketplaceRequest(
    id: map['local_id'] as String,
    unitId: map['unit_id'] as String,
    applicantName: map['applicant_name'] as String,
    applicantPhone: map['applicant_phone'] as String,
    message: map['message'] as String,
    status: map['status'] as String? ?? 'pending',
    createdAt: map['created_at'] as int? ?? 0,
  );
}

class Conversation {
  final String id;
  final String tenantId;
  final String tenantName;
  final String lastMessage;
  final int lastMessageTime;
  final int unreadCount;

  Conversation({
    required this.id,
    required this.tenantId,
    required this.tenantName,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.unreadCount,
  });

  Map<String, dynamic> toMap() => {
    'local_id': id,
    'tenant_id': tenantId,
    'tenant_name': tenantName,
    'last_message': lastMessage,
    'last_message_time': lastMessageTime,
    'unread_count': unreadCount,
  };

  factory Conversation.fromMap(Map<String, dynamic> map) => Conversation(
    id: map['local_id'] as String,
    tenantId: map['tenant_id'] as String,
    tenantName: map['tenant_name'] as String,
    lastMessage: map['last_message'] as String,
    lastMessageTime: map['last_message_time'] as int? ?? 0,
    unreadCount: map['unread_count'] as int? ?? 0,
  );
}

class MessageItem {
  final String id;
  final String conversationId;
  final String senderType; // 'tenant', 'landlord'
  final String content;
  final int sentAt;

  MessageItem({
    required this.id,
    required this.conversationId,
    required this.senderType,
    required this.content,
    required this.sentAt,
  });

  Map<String, dynamic> toMap() => {
    'local_id': id,
    'conversation_id': conversationId,
    'sender_type': senderType,
    'content': content,
    'sent_at': sentAt,
  };

  factory MessageItem.fromMap(Map<String, dynamic> map) => MessageItem(
    id: map['local_id'] as String,
    conversationId: map['conversation_id'] as String,
    senderType: map['sender_type'] as String,
    content: map['content'] as String,
    sentAt: map['sent_at'] as int? ?? 0,
  );
}

class NotificationItem {
  final String id;
  final String title;
  final String body;
  final String category; // 'payment', 'maintenance', 'lead'
  final bool read;
  final int createdAt;

  NotificationItem({
    required this.id,
    required this.title,
    required this.body,
    required this.category,
    required this.read,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
    'local_id': id,
    'title': title,
    'body': body,
    'category': category,
    'read': read ? 1 : 0,
    'created_at': createdAt,
  };

  factory NotificationItem.fromMap(Map<String, dynamic> map) => NotificationItem(
    id: map['local_id'] as String,
    title: map['title'] as String,
    body: map['body'] as String,
    category: map['category'] as String,
    read: (map['read'] as int? ?? 0) == 1,
    createdAt: map['created_at'] as int? ?? 0,
  );
}
