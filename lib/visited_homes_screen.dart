import 'package:flutter/material.dart';

import 'ui_elements.dart';
import 'database_functions.dart';
import 'comparators.dart';
import 'data_classes.dart';

class VisitedHomes extends StatefulWidget {
  const VisitedHomes({super.key});

  @override
  State<VisitedHomes> createState() => _VisitedHomesState();
}

class _VisitedHomesState extends State<VisitedHomes> {
  TextEditingController buildingNumC = TextEditingController();
  TextEditingController streetNameC = TextEditingController();
  TextEditingController cityC = TextEditingController();
  TextEditingController stateC = TextEditingController();
  TextEditingController zipCodeC = TextEditingController();

  int? houseStatus = 1;
  List<Icon> statusIcons = [
    Icon(Icons.monetization_on, color: Colors.green),
    Icon(Icons.alarm, color: Colors.amber),
    Icon(Icons.close, color: Colors.red)
  ];
  List<EasyText> statusTexts = [
    EasyText('Sold', 16, Colors.green),
    EasyText('Pending', 16, Colors.amber),
    EasyText('Rejected', 16, Colors.red)
  ];

  Color? pinColor;

  List<Widget> allAddressCards = [];

  @override
  void initState() {
    super.initState();
    allAddressCards = updateAddressCards();
    updatePinColor();
  }

  List<Widget> updateAddressCards() {
    if (visitedAddresses.isEmpty) {
      return [Center(child: EasyText('No visited addresses...', 20, Colors.grey[700]))];
    }

    List<Widget> addressCards = [];
    visitedAddresses.sort(compareAddressTimes);
    for (int i = 0; i < visitedAddresses.length; i++) {
      addressCards.add(addressCard(visitedAddresses[i]));
    }

    return addressCards;
  }

  bool fieldsFilled(bool checkBuildingNum) {
    if (checkBuildingNum && buildingNumC.text.isEmpty) {
      return false;
    }

    List<TextEditingController> necessaryCs = [streetNameC, cityC, stateC];
    for (int i = 0; i < necessaryCs.length; i++) {
      if (necessaryCs[i].text.isEmpty) {
        return false;
      }
    }
    return true;
  }

  void updatePinColor() {
    setState(() {
      if (fieldsFilled(false)) {
        pinColor = Colors.amber;
      } else {
        pinColor = Colors.grey[700];
      }
    });
  }

  VisitedAddress? addressMatch(VisitedAddress address) {
    for (int i = 0; i < visitedAddresses.length; i++) {
      if (address.toString().compareTo(visitedAddresses[i].toString()) == 0) {
        return visitedAddresses[i];
      }
    }
    return null;
  }

  void newAddress() async {
    if (fieldsFilled(true)) {
      VisitedAddress address = VisitedAddress(findFirstAvailableId(visitedAddresses), buildingNumC.text, streetNameC.text, cityC.text, stateC.text, zipCodeC.text, DateTime.now(), houseStatus! - 1);

      VisitedAddress? identicalAddress = addressMatch(address);
      if (identicalAddress == null) {
        await insertAddress(address);
        await refreshAddresses();
      } else {
        identicalAddress.timeOfVisit = DateTime.now();
        identicalAddress.status = houseStatus! - 1;
      }

      setState(() {
        allAddressCards = updateAddressCards();
      });
    } else {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Text('Missing information! Be sure to double check the location button in the top right.')
          );
        }
      );
    }
  }

  void deleteAddress(VisitedAddress address) async {
    await removeAddress(address.id);
    await refreshAddresses();
    setState(() {
      allAddressCards = updateAddressCards();
    });
  }

  void showAddressEditor(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
              content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text('Street name:  ', style: TextStyle(fontSize: 12)),
                          Flexible(child: TextField(controller: streetNameC, style: TextStyle(fontSize: 12)))
                        ]
                    ),
                    Row(
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text('City:  ', style: TextStyle(fontSize: 12)),
                          Flexible(child: TextField(controller: cityC, style: TextStyle(fontSize: 12)))
                        ]
                    ),
                    Row(
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text('State:  ', style: TextStyle(fontSize: 12)),
                          Flexible(child: TextField(controller: stateC, style: TextStyle(fontSize: 12)))
                        ]
                    ),
                    Row(
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text('ZIP code:  ', style: TextStyle(fontSize: 12)),
                          Flexible(child: TextField(controller: zipCodeC, style: TextStyle(fontSize: 12), decoration: InputDecoration(hintText: '(optional)', hintStyle: TextStyle(fontSize: 12, color: Colors.grey[700]))))
                        ]
                    ),
                    IconButton(onPressed: () {Navigator.pop(context); updatePinColor();}, icon: Icon(Icons.check, color: Colors.green))
                  ]
              )
          );
        }
    );
  }

  Widget addressCard(VisitedAddress address) {
    return Card(
        color: Colors.grey[800],
        child: Padding(
            padding: EdgeInsetsGeometry.all(5),
            child: IntrinsicHeight(child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Flexible(child: EasyText(address.timeToString(), 16, Colors.grey[400])),
                  VerticalDivider(color: Colors.grey[400]),
                  Expanded(child: EasyText(address.toString(), 16, Colors.grey[400])),
                  VerticalDivider(color: Colors.grey[400]),
                  Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        statusIcons[address.status],
                        statusTexts[address.status]
                      ]
                  ),
                  VerticalDivider(color: Colors.grey[400]),
                  Flexible(child: IconButton(
                      onPressed: () {deleteAddress(address);},
                      icon: Icon(Icons.delete, color: Colors.red)
                  ))
                ]
            ))
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Text('VISITED HOMES', style: TextStyle(color: Colors.white)),
            backgroundColor: Colors.grey[800],
            centerTitle: true
        ),
        backgroundColor: Colors.grey[900],
        body: Padding(padding: EdgeInsetsGeometry.fromLTRB(10, 5, 10, 5), child: Column(
          spacing: 10,
          children: [
            Row(
                children: [
                  Flexible(child: TextField(controller: buildingNumC, style: TextStyle(color: Colors.grey[400], fontSize: 18), decoration: InputDecoration(hintText: 'Building #', hintStyle: TextStyle(color: Colors.grey[600])))),
                  IconButton(
                      onPressed: newAddress,
                      icon: Icon(Icons.add, color: Colors.pink)
                  ),
                  DropdownButton(
                      dropdownColor: Colors.blueGrey[800],
                      value: houseStatus,
                      items: [
                        DropdownMenuItem(value: 1, child: Icon(Icons.monetization_on, color: Colors.green)),
                        DropdownMenuItem(value: 2, child: Icon(Icons.alarm, color: Colors.amber)),
                        DropdownMenuItem(value: 3, child: Icon(Icons.close, color: Colors.red))
                      ],
                      onChanged: (status) => setState(() => houseStatus = status)
                  ),
                  IconButton(
                      onPressed: () {showAddressEditor(context);},
                      icon: Icon(Icons.location_on_sharp, color: pinColor)
                  )
                ]
            ),
            Flexible (child: ListView(
                children: allAddressCards
            ))
          ]
        ))
    );
  }
}