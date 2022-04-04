import 'package:flutter/material.dart';

class PopupWidget extends StatefulWidget {
  const PopupWidget({Key key}) : super(key: key);

  @override
  _PopupWidgetState createState() => _PopupWidgetState();
}

enum menuitem { item1, item2, item3, item4 }

class _PopupWidgetState extends State<PopupWidget> {
  menuitem _mitem = menuitem.item1;
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.grey[200],
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16.0))),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'Filter',
                  style: TextStyle(fontSize: 25),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 24, right: 24, bottom: 10),
                width: 25,
                height: 25,
                decoration: const BoxDecoration(
                    shape: BoxShape.circle, color: Colors.blue),
                child: InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: const Center(
                    child: Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 15.0,
                    ),
                  ),
                ),
              ),
            ],
          ),
          ListTile(
            minVerticalPadding: 0,
            title: const Text('item1'),
            trailing: Radio<menuitem>(
              activeColor: Colors.orange,
              value: menuitem.item1,
              groupValue: _mitem,
              onChanged: (menuitem value) {
                setState(() {
                  _mitem = value;
                });
              },
            ),
          ),
          const Divider(
            thickness: 2,
            color: Colors.grey,
          ),
          ListTile(
            title: const Text('item2'),
            trailing: Radio<menuitem>(
              value: menuitem.item2,
              activeColor: Colors.orange,
              groupValue: _mitem,
              onChanged: (menuitem value) {
                setState(() {
                  _mitem = value;
                });
              },
            ),
          ),
          const Divider(
            thickness: 2,
            color: Colors.grey,
          ),
          ListTile(
            title: const Text('item3'),
            trailing: Radio<menuitem>(
              activeColor: Colors.orange,
              value: menuitem.item3,
              groupValue: _mitem,
              onChanged: (menuitem value) {
                setState(() {
                  _mitem = value;
                });
              },
            ),
          ),
          const Divider(
            thickness: 2,
            color: Colors.grey,
          ),
          ListTile(
            title: const Text('item4'),
            trailing: Radio<menuitem>(
              activeColor: Colors.orange,
              value: menuitem.item4,
              groupValue: _mitem,
              onChanged: (menuitem value) {
                setState(() {
                  _mitem = value;
                });
              },
            ),
          ),
          Center(
            child: TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Container(
                  width: 160,
                  height: 40,
                  decoration: const BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.all(Radius.circular(10.0))),
                  child: const Center(
                    child: Text('APPLY',
                        style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.w500,
                            color: Colors.white)),
                  )),
            ),
          ),
        ],
      ),
    );
  }
}
