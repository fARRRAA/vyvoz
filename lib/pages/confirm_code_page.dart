import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../db/api.dart';
import '../utils/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ConfirmCodePage extends StatefulWidget {
  final String code;
  final int userId;

  const ConfirmCodePage({Key? key, required this.code, required this.userId}) : super(key: key);

  @override
  _ConfirmCodePageState createState() => _ConfirmCodePageState();
}

class _ConfirmCodePageState extends State<ConfirmCodePage> {
  String inputCode = '';

  Future<bool> confirmCode() async {
    if (inputCode == widget.code) {
      try {
        await Api.fetchUserData(widget.userId);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('id', Api.user.id);
        await prefs.setInt('roleId', Api.user.roleId);
        
        if (Api.user.roleId == 2) {
          try {
            final sewer = await Api.getSewerById();
            Api.sewer = sewer;
            await prefs.setInt('sewerId', sewer.id);
            return true;
          } catch (ex) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Что-то пошло не так')),
            );
            return false;
          }
        }
        return true;
      } catch (ex) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Что-то пошло не так')),
        );
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/images/send_code.png'),
                const SizedBox(height: 16),
                const Text(
                  'Вам поступит звонок',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Введите в поле последние 4 цифры номера, с которого Вам позвонят',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15),
                ),
                const SizedBox(height: 24),
                PinField(
                  value: inputCode,
                  length: 4,
                  onChanged: (value) {
                    setState(() {
                      inputCode = value;
                    });
                  },
                ),
              ],
            ),
            Column(
              children: [
                ElevatedButton(
                  onPressed: () async {
                    if (await confirmCode()) {
                      Navigator.pushReplacementNamed(context, '/home');
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.triecoBaseBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 6),
                    child: Text(
                      'Подтвердить',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Отмена',
                    style: TextStyle(
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class PinField extends StatelessWidget {
  final String value;
  final int length;
  final Function(String) onChanged;

  const PinField({
    Key? key,
    required this.value,
    required this.length,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      keyboardType: TextInputType.number,
      inputFormatters: [
        LengthLimitingTextInputFormatter(length),
        FilteringTextInputFormatter.digitsOnly,
      ],
      decoration: InputDecoration(
        counterText: '',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: AppColors.triecoBaseBlue,
            width: 1.5,
          ),
        ),
      ),
      textAlign: TextAlign.center,
      style: const TextStyle(
        letterSpacing: 20,
        fontSize: 20,
      ),
    );
  }
} 