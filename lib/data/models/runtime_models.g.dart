// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'runtime_models.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetRuntimeStateCollection on Isar {
  IsarCollection<RuntimeState> get runtimeStates => this.collection();
}

const RuntimeStateSchema = CollectionSchema(
  name: r'RuntimeState',
  id: 8681060173702932018,
  properties: {
    r'completedNodes': PropertySchema(
      id: 0,
      name: r'completedNodes',
      type: IsarType.stringList,
    ),
    r'currentEpisodeId': PropertySchema(
      id: 1,
      name: r'currentEpisodeId',
      type: IsarType.string,
    ),
    r'currentSceneId': PropertySchema(
      id: 2,
      name: r'currentSceneId',
      type: IsarType.string,
    ),
    r'endingHistory': PropertySchema(
      id: 3,
      name: r'endingHistory',
      type: IsarType.stringList,
    ),
    r'isMusicEnabled': PropertySchema(
      id: 4,
      name: r'isMusicEnabled',
      type: IsarType.bool,
    ),
    r'isNotificationsEnabled': PropertySchema(
      id: 5,
      name: r'isNotificationsEnabled',
      type: IsarType.bool,
    ),
    r'isSfxEnabled': PropertySchema(
      id: 6,
      name: r'isSfxEnabled',
      type: IsarType.bool,
    ),
    r'saveSlotId': PropertySchema(
      id: 7,
      name: r'saveSlotId',
      type: IsarType.string,
    ),
    r'scriptVersion': PropertySchema(
      id: 8,
      name: r'scriptVersion',
      type: IsarType.string,
    ),
    r'unlockedGallery': PropertySchema(
      id: 9,
      name: r'unlockedGallery',
      type: IsarType.stringList,
    ),
    r'unlockedThreads': PropertySchema(
      id: 10,
      name: r'unlockedThreads',
      type: IsarType.stringList,
    ),
    r'userBio': PropertySchema(
      id: 11,
      name: r'userBio',
      type: IsarType.string,
    ),
    r'userName': PropertySchema(
      id: 12,
      name: r'userName',
      type: IsarType.string,
    ),
    r'variablesJson': PropertySchema(
      id: 13,
      name: r'variablesJson',
      type: IsarType.string,
    )
  },
  estimateSize: _runtimeStateEstimateSize,
  serialize: _runtimeStateSerialize,
  deserialize: _runtimeStateDeserialize,
  deserializeProp: _runtimeStateDeserializeProp,
  idName: r'id',
  indexes: {
    r'saveSlotId': IndexSchema(
      id: 3344169649220088400,
      name: r'saveSlotId',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'saveSlotId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _runtimeStateGetId,
  getLinks: _runtimeStateGetLinks,
  attach: _runtimeStateAttach,
  version: '3.1.0+1',
);

int _runtimeStateEstimateSize(
  RuntimeState object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.completedNodes.length * 3;
  {
    for (var i = 0; i < object.completedNodes.length; i++) {
      final value = object.completedNodes[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.currentEpisodeId.length * 3;
  bytesCount += 3 + object.currentSceneId.length * 3;
  bytesCount += 3 + object.endingHistory.length * 3;
  {
    for (var i = 0; i < object.endingHistory.length; i++) {
      final value = object.endingHistory[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.saveSlotId.length * 3;
  bytesCount += 3 + object.scriptVersion.length * 3;
  bytesCount += 3 + object.unlockedGallery.length * 3;
  {
    for (var i = 0; i < object.unlockedGallery.length; i++) {
      final value = object.unlockedGallery[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.unlockedThreads.length * 3;
  {
    for (var i = 0; i < object.unlockedThreads.length; i++) {
      final value = object.unlockedThreads[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.userBio.length * 3;
  bytesCount += 3 + object.userName.length * 3;
  bytesCount += 3 + object.variablesJson.length * 3;
  return bytesCount;
}

void _runtimeStateSerialize(
  RuntimeState object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeStringList(offsets[0], object.completedNodes);
  writer.writeString(offsets[1], object.currentEpisodeId);
  writer.writeString(offsets[2], object.currentSceneId);
  writer.writeStringList(offsets[3], object.endingHistory);
  writer.writeBool(offsets[4], object.isMusicEnabled);
  writer.writeBool(offsets[5], object.isNotificationsEnabled);
  writer.writeBool(offsets[6], object.isSfxEnabled);
  writer.writeString(offsets[7], object.saveSlotId);
  writer.writeString(offsets[8], object.scriptVersion);
  writer.writeStringList(offsets[9], object.unlockedGallery);
  writer.writeStringList(offsets[10], object.unlockedThreads);
  writer.writeString(offsets[11], object.userBio);
  writer.writeString(offsets[12], object.userName);
  writer.writeString(offsets[13], object.variablesJson);
}

RuntimeState _runtimeStateDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = RuntimeState();
  object.completedNodes = reader.readStringList(offsets[0]) ?? [];
  object.currentEpisodeId = reader.readString(offsets[1]);
  object.currentSceneId = reader.readString(offsets[2]);
  object.endingHistory = reader.readStringList(offsets[3]) ?? [];
  object.id = id;
  object.isMusicEnabled = reader.readBool(offsets[4]);
  object.isNotificationsEnabled = reader.readBool(offsets[5]);
  object.isSfxEnabled = reader.readBool(offsets[6]);
  object.saveSlotId = reader.readString(offsets[7]);
  object.scriptVersion = reader.readString(offsets[8]);
  object.unlockedGallery = reader.readStringList(offsets[9]) ?? [];
  object.unlockedThreads = reader.readStringList(offsets[10]) ?? [];
  object.userBio = reader.readString(offsets[11]);
  object.userName = reader.readString(offsets[12]);
  object.variablesJson = reader.readString(offsets[13]);
  return object;
}

P _runtimeStateDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringList(offset) ?? []) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readStringList(offset) ?? []) as P;
    case 4:
      return (reader.readBool(offset)) as P;
    case 5:
      return (reader.readBool(offset)) as P;
    case 6:
      return (reader.readBool(offset)) as P;
    case 7:
      return (reader.readString(offset)) as P;
    case 8:
      return (reader.readString(offset)) as P;
    case 9:
      return (reader.readStringList(offset) ?? []) as P;
    case 10:
      return (reader.readStringList(offset) ?? []) as P;
    case 11:
      return (reader.readString(offset)) as P;
    case 12:
      return (reader.readString(offset)) as P;
    case 13:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _runtimeStateGetId(RuntimeState object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _runtimeStateGetLinks(RuntimeState object) {
  return [];
}

void _runtimeStateAttach(
    IsarCollection<dynamic> col, Id id, RuntimeState object) {
  object.id = id;
}

extension RuntimeStateByIndex on IsarCollection<RuntimeState> {
  Future<RuntimeState?> getBySaveSlotId(String saveSlotId) {
    return getByIndex(r'saveSlotId', [saveSlotId]);
  }

  RuntimeState? getBySaveSlotIdSync(String saveSlotId) {
    return getByIndexSync(r'saveSlotId', [saveSlotId]);
  }

  Future<bool> deleteBySaveSlotId(String saveSlotId) {
    return deleteByIndex(r'saveSlotId', [saveSlotId]);
  }

  bool deleteBySaveSlotIdSync(String saveSlotId) {
    return deleteByIndexSync(r'saveSlotId', [saveSlotId]);
  }

  Future<List<RuntimeState?>> getAllBySaveSlotId(
      List<String> saveSlotIdValues) {
    final values = saveSlotIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'saveSlotId', values);
  }

  List<RuntimeState?> getAllBySaveSlotIdSync(List<String> saveSlotIdValues) {
    final values = saveSlotIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'saveSlotId', values);
  }

  Future<int> deleteAllBySaveSlotId(List<String> saveSlotIdValues) {
    final values = saveSlotIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'saveSlotId', values);
  }

  int deleteAllBySaveSlotIdSync(List<String> saveSlotIdValues) {
    final values = saveSlotIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'saveSlotId', values);
  }

  Future<Id> putBySaveSlotId(RuntimeState object) {
    return putByIndex(r'saveSlotId', object);
  }

  Id putBySaveSlotIdSync(RuntimeState object, {bool saveLinks = true}) {
    return putByIndexSync(r'saveSlotId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllBySaveSlotId(List<RuntimeState> objects) {
    return putAllByIndex(r'saveSlotId', objects);
  }

  List<Id> putAllBySaveSlotIdSync(List<RuntimeState> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'saveSlotId', objects, saveLinks: saveLinks);
  }
}

extension RuntimeStateQueryWhereSort
    on QueryBuilder<RuntimeState, RuntimeState, QWhere> {
  QueryBuilder<RuntimeState, RuntimeState, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension RuntimeStateQueryWhere
    on QueryBuilder<RuntimeState, RuntimeState, QWhereClause> {
  QueryBuilder<RuntimeState, RuntimeState, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<RuntimeState, RuntimeState, QAfterWhereClause> idNotEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<RuntimeState, RuntimeState, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<RuntimeState, RuntimeState, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<RuntimeState, RuntimeState, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<RuntimeState, RuntimeState, QAfterWhereClause> saveSlotIdEqualTo(
      String saveSlotId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'saveSlotId',
        value: [saveSlotId],
      ));
    });
  }

  QueryBuilder<RuntimeState, RuntimeState, QAfterWhereClause>
      saveSlotIdNotEqualTo(String saveSlotId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'saveSlotId',
              lower: [],
              upper: [saveSlotId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'saveSlotId',
              lower: [saveSlotId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'saveSlotId',
              lower: [saveSlotId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'saveSlotId',
              lower: [],
              upper: [saveSlotId],
              includeUpper: false,
            ));
      }
    });
  }
}

extension RuntimeStateQueryFilter
    on QueryBuilder<RuntimeState, RuntimeState, QFilterCondition> {
  QueryBuilder<RuntimeState, RuntimeState, QAfterFilterCondition>
      completedNodesElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'completedNodes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RuntimeState, RuntimeState, QAfterFilterCondition>
      completedNodesElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'completedNodes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RuntimeState, RuntimeState, QAfterFilterCondition>
      completedNodesElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'completedNodes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RuntimeState, RuntimeState, QAfterFilterCondition>
      completedNodesElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'completedNodes',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RuntimeState, RuntimeState, QAfterFilterCondition>
      completedNodesElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'completedNodes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RuntimeState, RuntimeState, QAfterFilterCondition>
      completedNodesElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'completedNodes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RuntimeState, RuntimeState, QAfterFilterCondition>
      completedNodesElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'completedNodes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RuntimeState, RuntimeState, QAfterFilterCondition>
      completedNodesElementMatches(String pattern,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'completedNodes',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RuntimeState, RuntimeState, QAfterFilterCondition>
      completedNodesElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'completedNodes',
        value: '',
      ));
    });
  }

  QueryBuilder<RuntimeState, RuntimeState, QAfterFilterCondition>
      completedNodesElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'completedNodes',
        value: '',
      ));
    });
  }

  QueryBuilder<RuntimeState, RuntimeState, QAfterFilterCondition>
      completedNodesLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'completedNodes',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<RuntimeState, RuntimeState, QAfterFilterCondition>
      completedNodesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'completedNodes',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<RuntimeState, RuntimeState, QAfterFilterCondition>
      completedNodesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'completedNodes',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<RuntimeState, RuntimeState, QAfterFilterCondition>
      completedNodesLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'completedNodes',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<RuntimeState, RuntimeState, QAfterFilterCondition>
      completedNodesLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'completedNodes',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<RuntimeState, RuntimeState, QAfterFilterCondition>
      completedNodesLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'completedNodes',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<RuntimeState, RuntimeState, QAfterFilterCondition>
      currentEpisodeIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'currentEpisodeId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RuntimeState, RuntimeState, QAfterFilterCondition>
      currentEpisodeIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'currentEpisodeId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RuntimeState, RuntimeState, QAfterFilterCondition>
      currentEpisodeIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'currentEpisodeId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RuntimeState, RuntimeState, QAfterFilterCondition>
      currentEpisodeIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'currentEpisodeId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RuntimeState, RuntimeState, QAfterFilterCondition>
      currentEpisodeIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'currentEpisodeId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RuntimeState, RuntimeState, QAfterFilterCondition>
      currentEpisodeIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'currentEpisodeId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RuntimeState, RuntimeState, QAfterFilterCondition>
      currentEpisodeIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'currentEpisodeId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RuntimeState, RuntimeState, QAfterFilterCondition>
      currentEpisodeIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'currentEpisodeId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RuntimeState, RuntimeState, QAfterFilterCondition>
      currentEpisodeIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'currentEpisodeId',
        value: '',
      ));
    });
  }

  QueryBuilder<RuntimeState, RuntimeState, QAfterFilterCondition>
      currentEpisodeIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'currentEpisodeId',
        value: '',
      ));
    });
  }

  QueryBuilder<RuntimeState, RuntimeState, QAfterFilterCondition>
      currentSceneIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'currentSceneId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RuntimeState, RuntimeState, QAfterFilterCondition>
      currentSceneIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'currentSceneId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RuntimeState, RuntimeState, QAfterFilterCondition>
      currentSceneIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'currentSceneId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RuntimeState, RuntimeState, QAfterFilterCondition>
      currentSceneIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'currentSceneId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RuntimeState, RuntimeState, QAfterFilterCondition>
      currentSceneIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'currentSceneId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RuntimeState, RuntimeState, QAfterFilterCondition>
      currentSceneIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'currentSceneId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RuntimeState, RuntimeState, QAfterFilterCondition>
      currentSceneIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'currentSceneId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RuntimeState, RuntimeState, QAfterFilterCondition>
      currentSceneIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'currentSceneId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RuntimeState, RuntimeState, QAfterFilterCondition>
      currentSceneIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'currentSceneId',
        value: '',
      ));
    });
  }

  QueryBuilder<RuntimeState, RuntimeState, QAfterFilterCondition>
      currentSceneIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'currentSceneId',
        value: '',
      ));
    });
  }

  QueryBuilder<RuntimeState, RuntimeState, QAfterFilterCondition>
      endingHistoryElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'endingHistory',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RuntimeState, RuntimeState, QAfterFilterCondition>
      endingHistoryElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'endingHistory',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RuntimeState, RuntimeState, QAfterFilterCondition>
      endingHistoryElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'endingHistory',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RuntimeState, RuntimeState, QAfterFilterCondition>
      endingHistoryElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'endingHistory',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RuntimeState, RuntimeState, QAfterFilterCondition>
      endingHistoryElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'endingHistory',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RuntimeState, RuntimeState, QAfterFilterCondition>
      endingHistoryElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'endingHistory',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RuntimeState, RuntimeState, QAfterFilterCondition>
      endingHistoryElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'endingHistory',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RuntimeState, RuntimeState, QAfterFilterCondition>
      endingHistoryElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'endingHistory',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RuntimeState, RuntimeState, QAfterFilterCondition>
      endingHistoryElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'endingHistory',
        value: '',
      ));
    });
  }

  QueryBuilder<RuntimeState, RuntimeState, QAfterFilterCondition>
      endingHistoryElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'endingHistory',
        value: '',
      ));
    });
  }

  QueryBuilder<RuntimeState, RuntimeState, QAfterFilterCondition>
      endingHistoryLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'endingHistory',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<RuntimeState, RuntimeState, QAfterFilterCondition>
      endingHistoryIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'endingHistory',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<RuntimeState, RuntimeState, QAfterFilterCondition>
      endingHistoryIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'endingHistory',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<RuntimeState, RuntimeState, QAfterFilterCondition>
      endingHistoryLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'endingHistory',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<RuntimeState, RuntimeState, QAfterFilterCondition>
      endingHistoryLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'endingHistory',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<RuntimeState, RuntimeState, QAfterFilterCondition>
      endingHistoryLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'endingHistory',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<RuntimeState, RuntimeState, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<RuntimeState, RuntimeState, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<RuntimeState, RuntimeState, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<RuntimeState, RuntimeState, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<RuntimeState, RuntimeState, QAfterFilterCondition>
      isMusicEnabledEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isMusicEnabled',
        value: value,
      ));
    });
  }

  QueryBuilder<RuntimeState, RuntimeState, QAfterFilterCondition>
      isNotificationsEnabledEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isNotificationsEnabled',
        value: value,
      ));
    });
  }

  QueryBuilder<RuntimeState, RuntimeState, QAfterFilterCondition>
      isSfxEnabledEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isSfxEnabled',
        value: value,
      ));
    });
  }

  QueryBuilder<RuntimeState, RuntimeState, QAfterFilterCondition>
      saveSlotIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'saveSlotId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RuntimeState, RuntimeState, QAfterFilterCondition>
      saveSlotIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'saveSlotId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RuntimeState, RuntimeState, QAfterFilterCondition>
      saveSlotIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'saveSlotId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RuntimeState, RuntimeState, QAfterFilterCondition>
      saveSlotIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'saveSlotId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RuntimeState, RuntimeState, QAfterFilterCondition>
      saveSlotIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'saveSlotId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RuntimeState, RuntimeState, QAfterFilterCondition>
      saveSlotIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'saveSlotId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RuntimeState, RuntimeState, QAfterFilterCondition>
      saveSlotIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'saveSlotId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RuntimeState, RuntimeState, QAfterFilterCondition>
      saveSlotIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'saveSlotId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RuntimeState, RuntimeState, QAfterFilterCondition>
      saveSlotIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'saveSlotId',
        value: '',
      ));
    });
  }

  QueryBuilder<RuntimeState, RuntimeState, QAfterFilterCondition>
      saveSlotIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'saveSlotId',
        value: '',
      ));
    });
  }

  QueryBuilder<RuntimeState, RuntimeState, QAfterFilterCondition>
      scriptVersionEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'scriptVersion',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RuntimeState, RuntimeState, QAfterFilterCondition>
      scriptVersionGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'scriptVersion',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RuntimeState, RuntimeState, QAfterFilterCondition>
      scriptVersionLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'scriptVersion',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RuntimeState, RuntimeState, QAfterFilterCondition>
      scriptVersionBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'scriptVersion',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RuntimeState, RuntimeState, QAfterFilterCondition>
      scriptVersionStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'scriptVersion',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RuntimeState, RuntimeState, QAfterFilterCondition>
      scriptVersionEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'scriptVersion',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RuntimeState, RuntimeState, QAfterFilterCondition>
      scriptVersionContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'scriptVersion',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RuntimeState, RuntimeState, QAfterFilterCondition>
      scriptVersionMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'scriptVersion',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RuntimeState, RuntimeState, QAfterFilterCondition>
      scriptVersionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'scriptVersion',
        value: '',
      ));
    });
  }

  QueryBuilder<RuntimeState, RuntimeState, QAfterFilterCondition>
      scriptVersionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'scriptVersion',
        value: '',
      ));
    });
  }

  QueryBuilder<RuntimeState, RuntimeState, QAfterFilterCondition>
      unlockedGalleryElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'unlockedGallery',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RuntimeState, RuntimeState, QAfterFilterCondition>
      unlockedGalleryElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'unlockedGallery',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RuntimeState, RuntimeState, QAfterFilterCondition>
      unlockedGalleryElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'unlockedGallery',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RuntimeState, RuntimeState, QAfterFilterCondition>
      unlockedGalleryElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'unlockedGallery',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RuntimeState, RuntimeState, QAfterFilterCondition>
      unlockedGalleryElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'unlockedGallery',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RuntimeState, RuntimeState, QAfterFilterCondition>
      unlockedGalleryElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'unlockedGallery',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RuntimeState, RuntimeState, QAfterFilterCondition>
      unlockedGalleryElementContains(String value,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'unlockedGallery',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RuntimeState, RuntimeState, QAfterFilterCondition>
      unlockedGalleryElementMatches(String pattern,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'unlockedGallery',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RuntimeState, RuntimeState, QAfterFilterCondition>
      unlockedGalleryElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'unlockedGallery',
        value: '',
      ));
    });
  }

  QueryBuilder<RuntimeState, RuntimeState, QAfterFilterCondition>
      unlockedGalleryElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'unlockedGallery',
        value: '',
      ));
    });
  }

  QueryBuilder<RuntimeState, RuntimeState, QAfterFilterCondition>
      unlockedGalleryLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'unlockedGallery',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<RuntimeState, RuntimeState, QAfterFilterCondition>
      unlockedGalleryIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'unlockedGallery',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<RuntimeState, RuntimeState, QAfterFilterCondition>
      unlockedGalleryIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'unlockedGallery',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<RuntimeState, RuntimeState, QAfterFilterCondition>
      unlockedGalleryLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'unlockedGallery',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<RuntimeState, RuntimeState, QAfterFilterCondition>
      unlockedGalleryLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'unlockedGallery',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<RuntimeState, RuntimeState, QAfterFilterCondition>
      unlockedGalleryLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'unlockedGallery',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<RuntimeState, RuntimeState, QAfterFilterCondition>
      unlockedThreadsElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'unlockedThreads',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RuntimeState, RuntimeState, QAfterFilterCondition>
      unlockedThreadsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'unlockedThreads',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RuntimeState, RuntimeState, QAfterFilterCondition>
      unlockedThreadsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'unlockedThreads',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RuntimeState, RuntimeState, QAfterFilterCondition>
      unlockedThreadsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'unlockedThreads',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RuntimeState, RuntimeState, QAfterFilterCondition>
      unlockedThreadsElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'unlockedThreads',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RuntimeState, RuntimeState, QAfterFilterCondition>
      unlockedThreadsElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'unlockedThreads',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RuntimeState, RuntimeState, QAfterFilterCondition>
      unlockedThreadsElementContains(String value,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'unlockedThreads',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RuntimeState, RuntimeState, QAfterFilterCondition>
      unlockedThreadsElementMatches(String pattern,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'unlockedThreads',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RuntimeState, RuntimeState, QAfterFilterCondition>
      unlockedThreadsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'unlockedThreads',
        value: '',
      ));
    });
  }

  QueryBuilder<RuntimeState, RuntimeState, QAfterFilterCondition>
      unlockedThreadsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'unlockedThreads',
        value: '',
      ));
    });
  }

  QueryBuilder<RuntimeState, RuntimeState, QAfterFilterCondition>
      unlockedThreadsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'unlockedThreads',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<RuntimeState, RuntimeState, QAfterFilterCondition>
      unlockedThreadsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'unlockedThreads',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<RuntimeState, RuntimeState, QAfterFilterCondition>
      unlockedThreadsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'unlockedThreads',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<RuntimeState, RuntimeState, QAfterFilterCondition>
      unlockedThreadsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'unlockedThreads',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<RuntimeState, RuntimeState, QAfterFilterCondition>
      unlockedThreadsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'unlockedThreads',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<RuntimeState, RuntimeState, QAfterFilterCondition>
      unlockedThreadsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'unlockedThreads',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<RuntimeState, RuntimeState, QAfterFilterCondition>
      userBioEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'userBio',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RuntimeState, RuntimeState, QAfterFilterCondition>
      userBioGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'userBio',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RuntimeState, RuntimeState, QAfterFilterCondition>
      userBioLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'userBio',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RuntimeState, RuntimeState, QAfterFilterCondition>
      userBioBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'userBio',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RuntimeState, RuntimeState, QAfterFilterCondition>
      userBioStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'userBio',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RuntimeState, RuntimeState, QAfterFilterCondition>
      userBioEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'userBio',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RuntimeState, RuntimeState, QAfterFilterCondition>
      userBioContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'userBio',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RuntimeState, RuntimeState, QAfterFilterCondition>
      userBioMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'userBio',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RuntimeState, RuntimeState, QAfterFilterCondition>
      userBioIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'userBio',
        value: '',
      ));
    });
  }

  QueryBuilder<RuntimeState, RuntimeState, QAfterFilterCondition>
      userBioIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'userBio',
        value: '',
      ));
    });
  }

  QueryBuilder<RuntimeState, RuntimeState, QAfterFilterCondition>
      userNameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'userName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RuntimeState, RuntimeState, QAfterFilterCondition>
      userNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'userName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RuntimeState, RuntimeState, QAfterFilterCondition>
      userNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'userName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RuntimeState, RuntimeState, QAfterFilterCondition>
      userNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'userName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RuntimeState, RuntimeState, QAfterFilterCondition>
      userNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'userName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RuntimeState, RuntimeState, QAfterFilterCondition>
      userNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'userName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RuntimeState, RuntimeState, QAfterFilterCondition>
      userNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'userName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RuntimeState, RuntimeState, QAfterFilterCondition>
      userNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'userName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RuntimeState, RuntimeState, QAfterFilterCondition>
      userNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'userName',
        value: '',
      ));
    });
  }

  QueryBuilder<RuntimeState, RuntimeState, QAfterFilterCondition>
      userNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'userName',
        value: '',
      ));
    });
  }

  QueryBuilder<RuntimeState, RuntimeState, QAfterFilterCondition>
      variablesJsonEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'variablesJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RuntimeState, RuntimeState, QAfterFilterCondition>
      variablesJsonGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'variablesJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RuntimeState, RuntimeState, QAfterFilterCondition>
      variablesJsonLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'variablesJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RuntimeState, RuntimeState, QAfterFilterCondition>
      variablesJsonBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'variablesJson',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RuntimeState, RuntimeState, QAfterFilterCondition>
      variablesJsonStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'variablesJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RuntimeState, RuntimeState, QAfterFilterCondition>
      variablesJsonEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'variablesJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RuntimeState, RuntimeState, QAfterFilterCondition>
      variablesJsonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'variablesJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RuntimeState, RuntimeState, QAfterFilterCondition>
      variablesJsonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'variablesJson',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<RuntimeState, RuntimeState, QAfterFilterCondition>
      variablesJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'variablesJson',
        value: '',
      ));
    });
  }

  QueryBuilder<RuntimeState, RuntimeState, QAfterFilterCondition>
      variablesJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'variablesJson',
        value: '',
      ));
    });
  }
}

extension RuntimeStateQueryObject
    on QueryBuilder<RuntimeState, RuntimeState, QFilterCondition> {}

extension RuntimeStateQueryLinks
    on QueryBuilder<RuntimeState, RuntimeState, QFilterCondition> {}

extension RuntimeStateQuerySortBy
    on QueryBuilder<RuntimeState, RuntimeState, QSortBy> {
  QueryBuilder<RuntimeState, RuntimeState, QAfterSortBy>
      sortByCurrentEpisodeId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentEpisodeId', Sort.asc);
    });
  }

  QueryBuilder<RuntimeState, RuntimeState, QAfterSortBy>
      sortByCurrentEpisodeIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentEpisodeId', Sort.desc);
    });
  }

  QueryBuilder<RuntimeState, RuntimeState, QAfterSortBy>
      sortByCurrentSceneId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentSceneId', Sort.asc);
    });
  }

  QueryBuilder<RuntimeState, RuntimeState, QAfterSortBy>
      sortByCurrentSceneIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentSceneId', Sort.desc);
    });
  }

  QueryBuilder<RuntimeState, RuntimeState, QAfterSortBy>
      sortByIsMusicEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isMusicEnabled', Sort.asc);
    });
  }

  QueryBuilder<RuntimeState, RuntimeState, QAfterSortBy>
      sortByIsMusicEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isMusicEnabled', Sort.desc);
    });
  }

  QueryBuilder<RuntimeState, RuntimeState, QAfterSortBy>
      sortByIsNotificationsEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isNotificationsEnabled', Sort.asc);
    });
  }

  QueryBuilder<RuntimeState, RuntimeState, QAfterSortBy>
      sortByIsNotificationsEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isNotificationsEnabled', Sort.desc);
    });
  }

  QueryBuilder<RuntimeState, RuntimeState, QAfterSortBy> sortByIsSfxEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSfxEnabled', Sort.asc);
    });
  }

  QueryBuilder<RuntimeState, RuntimeState, QAfterSortBy>
      sortByIsSfxEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSfxEnabled', Sort.desc);
    });
  }

  QueryBuilder<RuntimeState, RuntimeState, QAfterSortBy> sortBySaveSlotId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'saveSlotId', Sort.asc);
    });
  }

  QueryBuilder<RuntimeState, RuntimeState, QAfterSortBy>
      sortBySaveSlotIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'saveSlotId', Sort.desc);
    });
  }

  QueryBuilder<RuntimeState, RuntimeState, QAfterSortBy> sortByScriptVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scriptVersion', Sort.asc);
    });
  }

  QueryBuilder<RuntimeState, RuntimeState, QAfterSortBy>
      sortByScriptVersionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scriptVersion', Sort.desc);
    });
  }

  QueryBuilder<RuntimeState, RuntimeState, QAfterSortBy> sortByUserBio() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userBio', Sort.asc);
    });
  }

  QueryBuilder<RuntimeState, RuntimeState, QAfterSortBy> sortByUserBioDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userBio', Sort.desc);
    });
  }

  QueryBuilder<RuntimeState, RuntimeState, QAfterSortBy> sortByUserName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userName', Sort.asc);
    });
  }

  QueryBuilder<RuntimeState, RuntimeState, QAfterSortBy> sortByUserNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userName', Sort.desc);
    });
  }

  QueryBuilder<RuntimeState, RuntimeState, QAfterSortBy> sortByVariablesJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'variablesJson', Sort.asc);
    });
  }

  QueryBuilder<RuntimeState, RuntimeState, QAfterSortBy>
      sortByVariablesJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'variablesJson', Sort.desc);
    });
  }
}

extension RuntimeStateQuerySortThenBy
    on QueryBuilder<RuntimeState, RuntimeState, QSortThenBy> {
  QueryBuilder<RuntimeState, RuntimeState, QAfterSortBy>
      thenByCurrentEpisodeId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentEpisodeId', Sort.asc);
    });
  }

  QueryBuilder<RuntimeState, RuntimeState, QAfterSortBy>
      thenByCurrentEpisodeIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentEpisodeId', Sort.desc);
    });
  }

  QueryBuilder<RuntimeState, RuntimeState, QAfterSortBy>
      thenByCurrentSceneId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentSceneId', Sort.asc);
    });
  }

  QueryBuilder<RuntimeState, RuntimeState, QAfterSortBy>
      thenByCurrentSceneIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentSceneId', Sort.desc);
    });
  }

  QueryBuilder<RuntimeState, RuntimeState, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<RuntimeState, RuntimeState, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<RuntimeState, RuntimeState, QAfterSortBy>
      thenByIsMusicEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isMusicEnabled', Sort.asc);
    });
  }

  QueryBuilder<RuntimeState, RuntimeState, QAfterSortBy>
      thenByIsMusicEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isMusicEnabled', Sort.desc);
    });
  }

  QueryBuilder<RuntimeState, RuntimeState, QAfterSortBy>
      thenByIsNotificationsEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isNotificationsEnabled', Sort.asc);
    });
  }

  QueryBuilder<RuntimeState, RuntimeState, QAfterSortBy>
      thenByIsNotificationsEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isNotificationsEnabled', Sort.desc);
    });
  }

  QueryBuilder<RuntimeState, RuntimeState, QAfterSortBy> thenByIsSfxEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSfxEnabled', Sort.asc);
    });
  }

  QueryBuilder<RuntimeState, RuntimeState, QAfterSortBy>
      thenByIsSfxEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSfxEnabled', Sort.desc);
    });
  }

  QueryBuilder<RuntimeState, RuntimeState, QAfterSortBy> thenBySaveSlotId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'saveSlotId', Sort.asc);
    });
  }

  QueryBuilder<RuntimeState, RuntimeState, QAfterSortBy>
      thenBySaveSlotIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'saveSlotId', Sort.desc);
    });
  }

  QueryBuilder<RuntimeState, RuntimeState, QAfterSortBy> thenByScriptVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scriptVersion', Sort.asc);
    });
  }

  QueryBuilder<RuntimeState, RuntimeState, QAfterSortBy>
      thenByScriptVersionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scriptVersion', Sort.desc);
    });
  }

  QueryBuilder<RuntimeState, RuntimeState, QAfterSortBy> thenByUserBio() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userBio', Sort.asc);
    });
  }

  QueryBuilder<RuntimeState, RuntimeState, QAfterSortBy> thenByUserBioDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userBio', Sort.desc);
    });
  }

  QueryBuilder<RuntimeState, RuntimeState, QAfterSortBy> thenByUserName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userName', Sort.asc);
    });
  }

  QueryBuilder<RuntimeState, RuntimeState, QAfterSortBy> thenByUserNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userName', Sort.desc);
    });
  }

  QueryBuilder<RuntimeState, RuntimeState, QAfterSortBy> thenByVariablesJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'variablesJson', Sort.asc);
    });
  }

  QueryBuilder<RuntimeState, RuntimeState, QAfterSortBy>
      thenByVariablesJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'variablesJson', Sort.desc);
    });
  }
}

extension RuntimeStateQueryWhereDistinct
    on QueryBuilder<RuntimeState, RuntimeState, QDistinct> {
  QueryBuilder<RuntimeState, RuntimeState, QDistinct>
      distinctByCompletedNodes() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'completedNodes');
    });
  }

  QueryBuilder<RuntimeState, RuntimeState, QDistinct>
      distinctByCurrentEpisodeId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'currentEpisodeId',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<RuntimeState, RuntimeState, QDistinct> distinctByCurrentSceneId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'currentSceneId',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<RuntimeState, RuntimeState, QDistinct>
      distinctByEndingHistory() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'endingHistory');
    });
  }

  QueryBuilder<RuntimeState, RuntimeState, QDistinct>
      distinctByIsMusicEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isMusicEnabled');
    });
  }

  QueryBuilder<RuntimeState, RuntimeState, QDistinct>
      distinctByIsNotificationsEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isNotificationsEnabled');
    });
  }

  QueryBuilder<RuntimeState, RuntimeState, QDistinct> distinctByIsSfxEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isSfxEnabled');
    });
  }

  QueryBuilder<RuntimeState, RuntimeState, QDistinct> distinctBySaveSlotId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'saveSlotId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<RuntimeState, RuntimeState, QDistinct> distinctByScriptVersion(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'scriptVersion',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<RuntimeState, RuntimeState, QDistinct>
      distinctByUnlockedGallery() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'unlockedGallery');
    });
  }

  QueryBuilder<RuntimeState, RuntimeState, QDistinct>
      distinctByUnlockedThreads() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'unlockedThreads');
    });
  }

  QueryBuilder<RuntimeState, RuntimeState, QDistinct> distinctByUserBio(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'userBio', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<RuntimeState, RuntimeState, QDistinct> distinctByUserName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'userName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<RuntimeState, RuntimeState, QDistinct> distinctByVariablesJson(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'variablesJson',
          caseSensitive: caseSensitive);
    });
  }
}

extension RuntimeStateQueryProperty
    on QueryBuilder<RuntimeState, RuntimeState, QQueryProperty> {
  QueryBuilder<RuntimeState, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<RuntimeState, List<String>, QQueryOperations>
      completedNodesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'completedNodes');
    });
  }

  QueryBuilder<RuntimeState, String, QQueryOperations>
      currentEpisodeIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'currentEpisodeId');
    });
  }

  QueryBuilder<RuntimeState, String, QQueryOperations>
      currentSceneIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'currentSceneId');
    });
  }

  QueryBuilder<RuntimeState, List<String>, QQueryOperations>
      endingHistoryProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'endingHistory');
    });
  }

  QueryBuilder<RuntimeState, bool, QQueryOperations> isMusicEnabledProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isMusicEnabled');
    });
  }

  QueryBuilder<RuntimeState, bool, QQueryOperations>
      isNotificationsEnabledProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isNotificationsEnabled');
    });
  }

  QueryBuilder<RuntimeState, bool, QQueryOperations> isSfxEnabledProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isSfxEnabled');
    });
  }

  QueryBuilder<RuntimeState, String, QQueryOperations> saveSlotIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'saveSlotId');
    });
  }

  QueryBuilder<RuntimeState, String, QQueryOperations> scriptVersionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'scriptVersion');
    });
  }

  QueryBuilder<RuntimeState, List<String>, QQueryOperations>
      unlockedGalleryProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'unlockedGallery');
    });
  }

  QueryBuilder<RuntimeState, List<String>, QQueryOperations>
      unlockedThreadsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'unlockedThreads');
    });
  }

  QueryBuilder<RuntimeState, String, QQueryOperations> userBioProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'userBio');
    });
  }

  QueryBuilder<RuntimeState, String, QQueryOperations> userNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'userName');
    });
  }

  QueryBuilder<RuntimeState, String, QQueryOperations> variablesJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'variablesJson');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetChoiceRecordCollection on Isar {
  IsarCollection<ChoiceRecord> get choiceRecords => this.collection();
}

const ChoiceRecordSchema = CollectionSchema(
  name: r'ChoiceRecord',
  id: 1501382827985850812,
  properties: {
    r'choiceText': PropertySchema(
      id: 0,
      name: r'choiceText',
      type: IsarType.string,
    ),
    r'nodeId': PropertySchema(
      id: 1,
      name: r'nodeId',
      type: IsarType.string,
    ),
    r'saveSlotId': PropertySchema(
      id: 2,
      name: r'saveSlotId',
      type: IsarType.string,
    ),
    r'threadId': PropertySchema(
      id: 3,
      name: r'threadId',
      type: IsarType.string,
    ),
    r'timestamp': PropertySchema(
      id: 4,
      name: r'timestamp',
      type: IsarType.dateTime,
    )
  },
  estimateSize: _choiceRecordEstimateSize,
  serialize: _choiceRecordSerialize,
  deserialize: _choiceRecordDeserialize,
  deserializeProp: _choiceRecordDeserializeProp,
  idName: r'id',
  indexes: {
    r'saveSlotId': IndexSchema(
      id: 3344169649220088400,
      name: r'saveSlotId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'saveSlotId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'nodeId': IndexSchema(
      id: -6491850230428693976,
      name: r'nodeId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'nodeId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _choiceRecordGetId,
  getLinks: _choiceRecordGetLinks,
  attach: _choiceRecordAttach,
  version: '3.1.0+1',
);

int _choiceRecordEstimateSize(
  ChoiceRecord object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.choiceText.length * 3;
  bytesCount += 3 + object.nodeId.length * 3;
  bytesCount += 3 + object.saveSlotId.length * 3;
  bytesCount += 3 + object.threadId.length * 3;
  return bytesCount;
}

void _choiceRecordSerialize(
  ChoiceRecord object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.choiceText);
  writer.writeString(offsets[1], object.nodeId);
  writer.writeString(offsets[2], object.saveSlotId);
  writer.writeString(offsets[3], object.threadId);
  writer.writeDateTime(offsets[4], object.timestamp);
}

ChoiceRecord _choiceRecordDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = ChoiceRecord();
  object.choiceText = reader.readString(offsets[0]);
  object.id = id;
  object.nodeId = reader.readString(offsets[1]);
  object.saveSlotId = reader.readString(offsets[2]);
  object.threadId = reader.readString(offsets[3]);
  object.timestamp = reader.readDateTime(offsets[4]);
  return object;
}

P _choiceRecordDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readDateTime(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _choiceRecordGetId(ChoiceRecord object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _choiceRecordGetLinks(ChoiceRecord object) {
  return [];
}

void _choiceRecordAttach(
    IsarCollection<dynamic> col, Id id, ChoiceRecord object) {
  object.id = id;
}

extension ChoiceRecordQueryWhereSort
    on QueryBuilder<ChoiceRecord, ChoiceRecord, QWhere> {
  QueryBuilder<ChoiceRecord, ChoiceRecord, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension ChoiceRecordQueryWhere
    on QueryBuilder<ChoiceRecord, ChoiceRecord, QWhereClause> {
  QueryBuilder<ChoiceRecord, ChoiceRecord, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<ChoiceRecord, ChoiceRecord, QAfterWhereClause> idNotEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<ChoiceRecord, ChoiceRecord, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<ChoiceRecord, ChoiceRecord, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<ChoiceRecord, ChoiceRecord, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ChoiceRecord, ChoiceRecord, QAfterWhereClause> saveSlotIdEqualTo(
      String saveSlotId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'saveSlotId',
        value: [saveSlotId],
      ));
    });
  }

  QueryBuilder<ChoiceRecord, ChoiceRecord, QAfterWhereClause>
      saveSlotIdNotEqualTo(String saveSlotId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'saveSlotId',
              lower: [],
              upper: [saveSlotId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'saveSlotId',
              lower: [saveSlotId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'saveSlotId',
              lower: [saveSlotId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'saveSlotId',
              lower: [],
              upper: [saveSlotId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<ChoiceRecord, ChoiceRecord, QAfterWhereClause> nodeIdEqualTo(
      String nodeId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'nodeId',
        value: [nodeId],
      ));
    });
  }

  QueryBuilder<ChoiceRecord, ChoiceRecord, QAfterWhereClause> nodeIdNotEqualTo(
      String nodeId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'nodeId',
              lower: [],
              upper: [nodeId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'nodeId',
              lower: [nodeId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'nodeId',
              lower: [nodeId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'nodeId',
              lower: [],
              upper: [nodeId],
              includeUpper: false,
            ));
      }
    });
  }
}

extension ChoiceRecordQueryFilter
    on QueryBuilder<ChoiceRecord, ChoiceRecord, QFilterCondition> {
  QueryBuilder<ChoiceRecord, ChoiceRecord, QAfterFilterCondition>
      choiceTextEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'choiceText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChoiceRecord, ChoiceRecord, QAfterFilterCondition>
      choiceTextGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'choiceText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChoiceRecord, ChoiceRecord, QAfterFilterCondition>
      choiceTextLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'choiceText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChoiceRecord, ChoiceRecord, QAfterFilterCondition>
      choiceTextBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'choiceText',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChoiceRecord, ChoiceRecord, QAfterFilterCondition>
      choiceTextStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'choiceText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChoiceRecord, ChoiceRecord, QAfterFilterCondition>
      choiceTextEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'choiceText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChoiceRecord, ChoiceRecord, QAfterFilterCondition>
      choiceTextContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'choiceText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChoiceRecord, ChoiceRecord, QAfterFilterCondition>
      choiceTextMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'choiceText',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChoiceRecord, ChoiceRecord, QAfterFilterCondition>
      choiceTextIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'choiceText',
        value: '',
      ));
    });
  }

  QueryBuilder<ChoiceRecord, ChoiceRecord, QAfterFilterCondition>
      choiceTextIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'choiceText',
        value: '',
      ));
    });
  }

  QueryBuilder<ChoiceRecord, ChoiceRecord, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<ChoiceRecord, ChoiceRecord, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<ChoiceRecord, ChoiceRecord, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<ChoiceRecord, ChoiceRecord, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ChoiceRecord, ChoiceRecord, QAfterFilterCondition> nodeIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'nodeId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChoiceRecord, ChoiceRecord, QAfterFilterCondition>
      nodeIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'nodeId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChoiceRecord, ChoiceRecord, QAfterFilterCondition>
      nodeIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'nodeId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChoiceRecord, ChoiceRecord, QAfterFilterCondition> nodeIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'nodeId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChoiceRecord, ChoiceRecord, QAfterFilterCondition>
      nodeIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'nodeId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChoiceRecord, ChoiceRecord, QAfterFilterCondition>
      nodeIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'nodeId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChoiceRecord, ChoiceRecord, QAfterFilterCondition>
      nodeIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'nodeId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChoiceRecord, ChoiceRecord, QAfterFilterCondition> nodeIdMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'nodeId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChoiceRecord, ChoiceRecord, QAfterFilterCondition>
      nodeIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'nodeId',
        value: '',
      ));
    });
  }

  QueryBuilder<ChoiceRecord, ChoiceRecord, QAfterFilterCondition>
      nodeIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'nodeId',
        value: '',
      ));
    });
  }

  QueryBuilder<ChoiceRecord, ChoiceRecord, QAfterFilterCondition>
      saveSlotIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'saveSlotId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChoiceRecord, ChoiceRecord, QAfterFilterCondition>
      saveSlotIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'saveSlotId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChoiceRecord, ChoiceRecord, QAfterFilterCondition>
      saveSlotIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'saveSlotId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChoiceRecord, ChoiceRecord, QAfterFilterCondition>
      saveSlotIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'saveSlotId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChoiceRecord, ChoiceRecord, QAfterFilterCondition>
      saveSlotIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'saveSlotId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChoiceRecord, ChoiceRecord, QAfterFilterCondition>
      saveSlotIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'saveSlotId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChoiceRecord, ChoiceRecord, QAfterFilterCondition>
      saveSlotIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'saveSlotId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChoiceRecord, ChoiceRecord, QAfterFilterCondition>
      saveSlotIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'saveSlotId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChoiceRecord, ChoiceRecord, QAfterFilterCondition>
      saveSlotIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'saveSlotId',
        value: '',
      ));
    });
  }

  QueryBuilder<ChoiceRecord, ChoiceRecord, QAfterFilterCondition>
      saveSlotIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'saveSlotId',
        value: '',
      ));
    });
  }

  QueryBuilder<ChoiceRecord, ChoiceRecord, QAfterFilterCondition>
      threadIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'threadId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChoiceRecord, ChoiceRecord, QAfterFilterCondition>
      threadIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'threadId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChoiceRecord, ChoiceRecord, QAfterFilterCondition>
      threadIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'threadId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChoiceRecord, ChoiceRecord, QAfterFilterCondition>
      threadIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'threadId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChoiceRecord, ChoiceRecord, QAfterFilterCondition>
      threadIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'threadId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChoiceRecord, ChoiceRecord, QAfterFilterCondition>
      threadIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'threadId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChoiceRecord, ChoiceRecord, QAfterFilterCondition>
      threadIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'threadId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChoiceRecord, ChoiceRecord, QAfterFilterCondition>
      threadIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'threadId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChoiceRecord, ChoiceRecord, QAfterFilterCondition>
      threadIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'threadId',
        value: '',
      ));
    });
  }

  QueryBuilder<ChoiceRecord, ChoiceRecord, QAfterFilterCondition>
      threadIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'threadId',
        value: '',
      ));
    });
  }

  QueryBuilder<ChoiceRecord, ChoiceRecord, QAfterFilterCondition>
      timestampEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'timestamp',
        value: value,
      ));
    });
  }

  QueryBuilder<ChoiceRecord, ChoiceRecord, QAfterFilterCondition>
      timestampGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'timestamp',
        value: value,
      ));
    });
  }

  QueryBuilder<ChoiceRecord, ChoiceRecord, QAfterFilterCondition>
      timestampLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'timestamp',
        value: value,
      ));
    });
  }

  QueryBuilder<ChoiceRecord, ChoiceRecord, QAfterFilterCondition>
      timestampBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'timestamp',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension ChoiceRecordQueryObject
    on QueryBuilder<ChoiceRecord, ChoiceRecord, QFilterCondition> {}

extension ChoiceRecordQueryLinks
    on QueryBuilder<ChoiceRecord, ChoiceRecord, QFilterCondition> {}

extension ChoiceRecordQuerySortBy
    on QueryBuilder<ChoiceRecord, ChoiceRecord, QSortBy> {
  QueryBuilder<ChoiceRecord, ChoiceRecord, QAfterSortBy> sortByChoiceText() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'choiceText', Sort.asc);
    });
  }

  QueryBuilder<ChoiceRecord, ChoiceRecord, QAfterSortBy>
      sortByChoiceTextDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'choiceText', Sort.desc);
    });
  }

  QueryBuilder<ChoiceRecord, ChoiceRecord, QAfterSortBy> sortByNodeId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nodeId', Sort.asc);
    });
  }

  QueryBuilder<ChoiceRecord, ChoiceRecord, QAfterSortBy> sortByNodeIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nodeId', Sort.desc);
    });
  }

  QueryBuilder<ChoiceRecord, ChoiceRecord, QAfterSortBy> sortBySaveSlotId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'saveSlotId', Sort.asc);
    });
  }

  QueryBuilder<ChoiceRecord, ChoiceRecord, QAfterSortBy>
      sortBySaveSlotIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'saveSlotId', Sort.desc);
    });
  }

  QueryBuilder<ChoiceRecord, ChoiceRecord, QAfterSortBy> sortByThreadId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'threadId', Sort.asc);
    });
  }

  QueryBuilder<ChoiceRecord, ChoiceRecord, QAfterSortBy> sortByThreadIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'threadId', Sort.desc);
    });
  }

  QueryBuilder<ChoiceRecord, ChoiceRecord, QAfterSortBy> sortByTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.asc);
    });
  }

  QueryBuilder<ChoiceRecord, ChoiceRecord, QAfterSortBy> sortByTimestampDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.desc);
    });
  }
}

extension ChoiceRecordQuerySortThenBy
    on QueryBuilder<ChoiceRecord, ChoiceRecord, QSortThenBy> {
  QueryBuilder<ChoiceRecord, ChoiceRecord, QAfterSortBy> thenByChoiceText() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'choiceText', Sort.asc);
    });
  }

  QueryBuilder<ChoiceRecord, ChoiceRecord, QAfterSortBy>
      thenByChoiceTextDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'choiceText', Sort.desc);
    });
  }

  QueryBuilder<ChoiceRecord, ChoiceRecord, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<ChoiceRecord, ChoiceRecord, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<ChoiceRecord, ChoiceRecord, QAfterSortBy> thenByNodeId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nodeId', Sort.asc);
    });
  }

  QueryBuilder<ChoiceRecord, ChoiceRecord, QAfterSortBy> thenByNodeIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nodeId', Sort.desc);
    });
  }

  QueryBuilder<ChoiceRecord, ChoiceRecord, QAfterSortBy> thenBySaveSlotId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'saveSlotId', Sort.asc);
    });
  }

  QueryBuilder<ChoiceRecord, ChoiceRecord, QAfterSortBy>
      thenBySaveSlotIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'saveSlotId', Sort.desc);
    });
  }

  QueryBuilder<ChoiceRecord, ChoiceRecord, QAfterSortBy> thenByThreadId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'threadId', Sort.asc);
    });
  }

  QueryBuilder<ChoiceRecord, ChoiceRecord, QAfterSortBy> thenByThreadIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'threadId', Sort.desc);
    });
  }

  QueryBuilder<ChoiceRecord, ChoiceRecord, QAfterSortBy> thenByTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.asc);
    });
  }

  QueryBuilder<ChoiceRecord, ChoiceRecord, QAfterSortBy> thenByTimestampDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.desc);
    });
  }
}

extension ChoiceRecordQueryWhereDistinct
    on QueryBuilder<ChoiceRecord, ChoiceRecord, QDistinct> {
  QueryBuilder<ChoiceRecord, ChoiceRecord, QDistinct> distinctByChoiceText(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'choiceText', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ChoiceRecord, ChoiceRecord, QDistinct> distinctByNodeId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'nodeId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ChoiceRecord, ChoiceRecord, QDistinct> distinctBySaveSlotId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'saveSlotId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ChoiceRecord, ChoiceRecord, QDistinct> distinctByThreadId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'threadId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ChoiceRecord, ChoiceRecord, QDistinct> distinctByTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'timestamp');
    });
  }
}

extension ChoiceRecordQueryProperty
    on QueryBuilder<ChoiceRecord, ChoiceRecord, QQueryProperty> {
  QueryBuilder<ChoiceRecord, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<ChoiceRecord, String, QQueryOperations> choiceTextProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'choiceText');
    });
  }

  QueryBuilder<ChoiceRecord, String, QQueryOperations> nodeIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'nodeId');
    });
  }

  QueryBuilder<ChoiceRecord, String, QQueryOperations> saveSlotIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'saveSlotId');
    });
  }

  QueryBuilder<ChoiceRecord, String, QQueryOperations> threadIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'threadId');
    });
  }

  QueryBuilder<ChoiceRecord, DateTime, QQueryOperations> timestampProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'timestamp');
    });
  }
}
