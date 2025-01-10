import 'package:flutter/material.dart';
import 'package:flutter_ecrm/constants/global_variables.dart';
import 'package:flutter_ecrm/models/user.dart';

class FetchBranchProvider extends ChangeNotifier {
  User _branch = User(id: "", name: "Tất cả", email: "", password: "", address: "", type: "branch", token: "", cart: [], publicKey: "", privateKey: "");
  List<User> _listBranch = [];
  User branchDefault = User(id: "", name: "Tất cả", email: "", password: "", address: "", type: "branch", token: "", cart: [], publicKey: "", privateKey: "");

  User get branch => _branch;
  List<User> get listBranch => _listBranch;

  void setBranch(User branch) {
    _branch = branch;
    notifyListeners();
  }

  void setListBranch() {
    _branch = branchDefault;
    _listBranch = [_branch, ...GlobalVariables.branches];
    notifyListeners();
  }
}
