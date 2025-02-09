// Copyright (c) 2023, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:_fe_analyzer_shared/src/macros/api.dart';

/*macro*/ class AddClass
    implements ClassTypesMacro, MethodTypesMacro, MixinTypesMacro {
  final String name;

  const AddClass(this.name);

  @override
  buildTypesForClass(clazz, builder) async {
    _add(builder);
  }

  @override
  buildTypesForMethod(method, builder) {
    _add(builder);
  }

  @override
  buildTypesForMixin(method, builder) {
    _add(builder);
  }

  void _add(TypeBuilder builder) {
    final code = 'class $name {}';
    builder.declareType(name, DeclarationCode.fromString(code));
  }
}

/*macro*/ class AddFunction
    implements
        ClassDeclarationsMacro,
        MethodDeclarationsMacro,
        MixinDeclarationsMacro {
  final String name;

  const AddFunction(this.name);

  @override
  buildDeclarationsForClass(clazz, builder) async {
    _add(builder);
  }

  @override
  buildDeclarationsForMethod(method, builder) {
    _add(builder);
  }

  @override
  buildDeclarationsForMixin(method, builder) {
    _add(builder);
  }

  void _add(DeclarationBuilder builder) {
    final code = 'void $name() {}';
    final declaration = DeclarationCode.fromString(code);
    builder.declareInLibrary(declaration);
  }
}

/*macro*/ class AddHierarchyMethod implements ClassDeclarationsMacro {
  final String name;

  const AddHierarchyMethod(this.name);

  @override
  buildDeclarationsForClass(clazz, builder) async {
    // builder.typeDeclarationOf(identifier);
    final methods = (await Future.wait(
      clazz.interfaces.map(
        (interface) async {
          final type = await builder.typeDeclarationOf(interface.identifier);
          type as IntrospectableType;
          return await builder.methodsOf(type);
        },
      ),
    ))
        .expand((element) => element)
        .toList();
    final methodsStr = methods.map((e) => e.identifier.name).join('_');

    final compoundName = methodsStr.isEmpty ? name : '${methodsStr}_$name';
    final code = '  void $compoundName() {}';
    final declaration = DeclarationCode.fromString(code);
    builder.declareInType(declaration);
  }
}
