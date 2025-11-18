# 📧 Automatic Notification System

## Overview
Automatic email and SMS notifications to technicians when tickets are assigned or created. Keeps technicians informed in real-time about new work assignments.

---

## ✨ Features

### 🎯 Notification Triggers:

**1. Ticket Assignment**
- Admin/Manager assigns ticket to technician
- Technician receives immediate notification
- Email + SMS (if configured)

**2. New Ticket Creation**
- User creates ticket with auto-assignment
- Assigned technician gets notified instantly
- Ensures quick response time

---

## 📨 Notification Types

### Email Notifications
- ✅ Professional HTML templates
- ✅ Ticket details included
- ✅ Priority color-coding
- ✅ Direct links to system
- ✅ Works with any email provider

### SMS Notifications (Optional)
- ✅ Short, concise messages
- ✅ Instant delivery via Twilio
- ✅ Includes ticket ID and priority
- ✅ Perfect for urgent tickets

---

## 🔧 Setup Instructions

### Step 1: Install Dependencies

```bash
cd backend
pip install python-dotenv twilio
```

**Packages:**
- `python-dotenv` - For environment variables ✅
- `twilio` - For SMS notifications (optional)

### Step 2: Configure Email

#### Option A: Gmail (Recommended for Testing)

1. **Enable 2-Step Verification:**
   - Go to Google Account Settings
   - Security → 2-Step Verification → Turn On

2. **Create App Password:**
   - Go to: https://myaccount.google.com/apppasswords
   - Select "Mail" and "Windows Computer"
   - Click "Generate"
   - Copy the 16-character password

3. **Create `.env` file:**
```bash
cd backend
copy .env.example .env
```

4. **Edit `.env` file:**
```env
# Email Settings
ENABLE_EMAIL=true
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=your-email@gmail.com
SMTP_PASSWORD=your-16-char-app-password
FROM_EMAIL=noreply@yourcompany.com
FROM_NAME=IT Help Desk System
```

#### Option B: Other Email Providers

**Outlook/Hotmail:**
```env
SMTP_HOST=smtp-mail.outlook.com
SMTP_PORT=587
SMTP_USER=your-email@outlook.com
SMTP_PASSWORD=your-password
```

### Step 4: Restart Backend

```bash
# Stop backend
Ctrl+C

# Restart
cd ..
START_BACKEND.bat
```

---

## 📋 Configuration Options

### `.env` File Settings:

| Setting | Description | Default | Required |
|---------|-------------|---------|----------|
| `ENABLE_EMAIL` | Enable/disable emails | `true` | Yes |
| `ENABLE_SMS` | Enable/disable SMS | `false` | No |
| `SMTP_HOST` | Email server | `smtp.gmail.com` | If email enabled |
| `SMTP_PORT` | SMTP port | `587` | If email enabled |
| `SMTP_USER` | Email username | - | If email enabled |
| `SMTP_PASSWORD` | Email password | - | If email enabled |
| `FROM_EMAIL` | Sender email | Same as SMTP_USER | No |
| `FROM_NAME` | Sender name | `IT Help Desk System` | No |
| `TWILIO_ACCOUNT_SID` | Twilio Account SID | - | If SMS enabled |
| `TWILIO_AUTH_TOKEN` | Twilio Auth Token | - | If SMS enabled |
| `TWILIO_PHONE_NUMBER` | Twilio phone | - | If SMS enabled |

---

## 📧 Email Templates

### Ticket Assignment Email:

```
Subject: New Ticket Assigned: #123 - Printer Not Working

Hi John Smith,

A new ticket has been assigned to you.

Ticket Details:
• Ticket ID: #123
• Title: Printer Not Working
• Priority: HIGH
• Assigned by: Administrator

Please log in to the IT Help Desk system to view and manage this ticket.

Best regards,
IT Help Desk System
```

### New Ticket Creation Email:

```
Subject: New Support Request: #124 - Network Issue

Hi John Smith,

A new support ticket has been created and assigned to you.

Ticket Details:
• Ticket ID: #124
• Title: Network Issue
• Category: Network
• Priority: MEDIUM
• Created by: Jane Doe

Please review and respond to this ticket as soon as possible.

Best regards,
IT Help Desk System
```

## 🔄 How It Works

### Ticket Assignment Flow:

```
Admin/Manager assigns ticket to Technician
         ↓
Backend update_ticket() endpoint
         ↓
Check if assignee changed
         ↓
Get technician details (email, phone, name)
         ↓
NotificationService.notify_ticket_assigned()
         ↓
        / \
       /   \
   Email   SMS
     ↓       ↓
Technician receives notification
```

### Ticket Creation Flow:

```
User/Admin creates ticket with assignee
         ↓
Backend create_ticket() endpoint
         ↓
Save ticket to database
         ↓
Check if ticket has assignee
         ↓
Get technician details
         ↓
NotificationService.notify_new_ticket_created()
         ↓
        / \
       /   \
   Email   SMS
     ↓       ↓
Technician receives notification
```

---

## 🧪 Testing

### Test 1: Email Configuration

```bash
# After configuring .env, restart backend
# Check terminal output for:
[Email] SMTP credentials configured
```

### Test 2: Assign Ticket

1. Login as admin/manager
2. Go to Admin Dashboard
3. Assign ticket to technician
4. Check technician's email
5. ✅ Expected: Email received within seconds

### Test 3: Create Ticket with Assignment

1. Login as admin
2. Create new ticket
3. Assign to technician during creation
4. Check technician's email
5. ✅ Expected: Email received

### Test 4: SMS (If Configured)

1. Add phone number to technician user
2. Assign ticket
3. Check phone for SMS
4. ✅ Expected: SMS received

---

## 🐛 Troubleshooting

### Issue: No Emails Sent

**Check 1: Configuration**
```bash
# Verify .env file exists
ls backend/.env

# Check for errors in terminal
# Look for: [Email Error]
```

**Check 2: Gmail App Password**
- Must use App Password, not regular password
- 2-Step Verification must be enabled
- Format: 16 characters, no spaces

**Check 3: Environment Variables**
```bash
# Restart backend after changing .env
```

### Issue: Email Sent But Not Received

**Check 1: Spam Folder**
- Check technician's spam/junk folder
- Mark as "Not Spam"

**Check 2: Technician Email**
- Verify email in user profile
- Must be valid email address

### Issue: SMS Not Working

**Check 1: Twilio Credits**
- Login to Twilio console
- Check remaining balance
- Free trial: $15 credit

**Check 2: Phone Number Format**
- Must be E.164 format: +1234567890
- Include country code

**Check 3: Twilio Package**
```bash
pip install twilio
```

---

## 💡 Best Practices

### Email:
✅ **Use App Passwords** - More secure than regular passwords  
✅ **Professional From Name** - "IT Help Desk System"  
✅ **Clear Subject Lines** - Include ticket ID  
✅ **HTML Templates** - Better readability  

### SMS:
✅ **Keep Messages Short** - SMS has character limits  
✅ **Include Ticket ID** - For quick reference  
✅ **Show Priority** - HIGH, MEDIUM, LOW  
✅ **Save Credits** - Use for urgent tickets only  

### General:
✅ **Test Configuration** - Before going live  
✅ **Monitor Logs** - Check for errors  
✅ **Update Emails** - Keep technician emails current  
✅ **Graceful Failure** - Ticket still saved if notification fails  

---

## 🔒 Security Notes

### Email Security:
- ✅ App Passwords are isolated from main account
- ✅ Can revoke App Password anytime
- ✅ Credentials stored in `.env` (not in code)
- ⚠️ Never commit `.env` to version control

### SMS Security:
- ✅ Twilio credentials encrypted
- ✅ Phone numbers validated
- ✅ Rate limiting in place

### Data Privacy:
- ✅ Only ticket summary sent (not full details)
- ✅ No sensitive data in SMS
- ✅ Technician-specific notifications only

---

## 📊 Implementation Details

### Files Modified:

**1. backend/notifications.py** (NEW)
- `EmailService` - Email sending
- `SMSService` - SMS via Twilio
- `NotificationService` - Coordination
- Templates for both notification types

**2. backend/main.py**
- Import `NotificationService`
- Add `phone` field to User model
- Update `create_ticket()` endpoint
- Update `update_ticket()` endpoint

**3. backend/.env.example** (NEW)
- Configuration template
- All available settings
- Comments and examples

### Database Changes:

**User Model:**
```python
class User(Base):
    # ... existing fields ...
    phone = Column(String, nullable=True)  # ← New field
```

**Migration:**
- Run `UPGRADE_DATABASE.bat` to add phone field
- Existing users: phone will be NULL (emails still work)
- Update user profiles to add phone numbers

---

## 🚀 Quick Start

### For Email Only (Easiest):

```bash
# 1. Create Gmail App Password
# 2. Create .env file
cd backend
copy .env.example .env

# 3. Edit .env with your Gmail
ENABLE_EMAIL=true
SMTP_USER=your-email@gmail.com
SMTP_PASSWORD=your-app-password

# 4. Restart backend
cd ..
START_BACKEND.bat

# 5. Test by assigning a ticket!
```

### For Email + SMS:

```bash
# 1-4. Same as above

# 5. Sign up for Twilio

# 6. Add to .env
ENABLE_SMS=true
TWILIO_ACCOUNT_SID=your-sid
TWILIO_AUTH_TOKEN=your-token
TWILIO_PHONE_NUMBER=+1234567890

# 7. Install Twilio
cd backend
pip install twilio

# 8. Restart and test!
```

---

## 📈 Benefits

### For Technicians:
✅ **Instant Awareness** - Know immediately when assigned  
✅ **No Need to Check System** - Notifications come to them  
✅ **Priority Information** - See urgency at a glance  
✅ **Mobile Friendly** - SMS works anywhere  

### For Admins/Managers:
✅ **Confidence** - Know technicians are notified  
✅ **Faster Response** - Reduced time to first action  
✅ **Better Coordination** - Clear communication trail  
✅ **Professional** - Automated, consistent notifications  

### For Users:
✅ **Faster Service** - Technicians respond quicker  
✅ **Transparency** - Clear assignment process  
✅ **Reliability** - No assignments get missed  

---

## 🔮 Future Enhancements

### Planned Features:
- [ ] Notification preferences per user
- [ ] Digest emails (daily summary)
- [ ] Slack/Teams integration
- [ ] Push notifications
- [ ] Customizable templates
- [ ] Notification history/logs
- [ ] User notification when ticket resolved
- [ ] Escalation notifications

---

## ✅ Summary

**Feature:** Automatic Email/SMS Notifications  
**Status:** ✅ Complete and ready to use  
**Setup Time:** 5-10 minutes  
**Cost:** Free (Gmail) or $15 credit (Twilio)  
**Impact:** Faster response times, better communication  

**Key Points:**
- ✅ Automatic notifications when tickets assigned
- ✅ Email with Gmail/Outlook/Yahoo
- ✅ Optional SMS via Twilio
- ✅ Professional HTML templates
- ✅ Priority color-coding
- ✅ Graceful failure (won't break system)
- ✅ Easy configuration via `.env` file

**Ready to Use:**
1. Configure `.env` file
2. Restart backend
3. Assign a ticket
4. Watch notifications fly! 🚀

---

## 📞 Support

### Need Help?

1. Check troubleshooting section
2. Verify `.env` configuration
3. Check backend terminal for errors
4. Test with single email first
5. Add SMS after email works

### Common Questions:

**Q: Do I need Twilio for emails?**  
A: No! Emails work with just Gmail/Outlook. Twilio is only for SMS.

**Q: Will it work without .env?**  
A: System will work, but notifications will be skipped. Check terminal logs.

**Q: Can I use my regular Gmail password?**  
A: No, you must create an App Password. Regular passwords won't work.

**Q: What if notification fails?**  
A: Ticket is still saved. Error is logged but doesn't break the system.

**Q: Can users get notifications too?**  
A: Currently only technicians. User notifications coming in future update!

---

**🎉 Your IT Help Desk now has automatic notifications!**
