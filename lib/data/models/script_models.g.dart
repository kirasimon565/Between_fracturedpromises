// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'script_models.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetScriptMessageCollection on Isar {
  IsarCollection<ScriptMessage> get scriptMessages => this.collection();
}

const ScriptMessageSchema = CollectionSchema(
  name: r'ScriptMessage',
  id: 2669721021738011609,
  properties: {
    r'choicesJson': PropertySchema(
      id: 0,
      name: r'choicesJson',
      type: IsarType.string,
    ),
    r'content': PropertySchema(
      id: 1,
      name: r'content',
      type: IsarType.string,
    ),
    r'delay': PropertySchema(
      id: 2,
      name: r'delay',
      type: IsarType.long,
    ),
    r'metadataJson': PropertySchema(
      id: 3,
      name: r'metadataJson',
      type: IsarType.string,
    ),
    r'orderIndex': PropertySchema(
      id: 4,
      name: r'orderIndex',
      type: IsarType.long,
    ),
    r'sceneId': PropertySchema(
      id: 5,
      name: r'sceneId',
      type: IsarType.string,
    ),
    r'scriptId': PropertySchema(
      id: 6,
      name: r'scriptId',
      type: IsarType.string,
    ),
    r'sender': PropertySchema(
      id: 7,
      name: r'sender',
      type: IsarType.string,
    ),
    r'threadId': PropertySchema(
      id: 8,
      name: r'threadId',
      type: IsarType.string,
    ),
    r'type': PropertySchema(
      id: 9,
      name: r'type',
      type: IsarType.string,
    )
  },
  estimateSize: _scriptMessageEstimateSize,
  serialize: _scriptMessageSerialize,
  deserialize: _scriptMessageDeserialize,
  deserializeProp: _scriptMessageDeserializeProp,
  idName: r'id',
  indexes: {
    r'scriptId': IndexSchema(
      id: 308675172196154073,
      name: r'scriptId',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'scriptId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'threadId': IndexSchema(
      id: -1397508362477071783,
      name: r'threadId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'threadId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _scriptMessageGetId,
  getLinks: _scriptMessageGetLinks,
  attach: _scriptMessageAttach,
  version: '3.1.0+1',
);

int _scriptMessageEstimateSize(
  ScriptMessage object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.choicesJson;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.content.length * 3;
  {
    final value = object.metadataJson;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.sceneId.length * 3;
  bytesCount += 3 + object.scriptId.length * 3;
  bytesCount += 3 + object.sender.length * 3;
  bytesCount += 3 + object.threadId.length * 3;
  bytesCount += 3 + object.type.length * 3;
  return bytesCount;
}

void _scriptMessageSerialize(
  ScriptMessage object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.choicesJson);
  writer.writeString(offsets[1], object.content);
  writer.writeLong(offsets[2], object.delay);
  writer.writeString(offsets[3], object.metadataJson);
  writer.writeLong(offsets[4], object.orderIndex);
  writer.writeString(offsets[5], object.sceneId);
  writer.writeString(offsets[6], object.scriptId);
  writer.writeString(offsets[7], object.sender);
  writer.writeString(offsets[8], object.threadId);
  writer.writeString(offsets[9], object.type);
}

ScriptMessage _scriptMessageDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = ScriptMessage();
  object.choicesJson = reader.readStringOrNull(offsets[0]);
  object.content = reader.readString(offsets[1]);
  object.delay = reader.readLong(offsets[2]);
  object.id = id;
  object.metadataJson = reader.readStringOrNull(offsets[3]);
  object.orderIndex = reader.readLong(offsets[4]);
  object.sceneId = reader.readString(offsets[5]);
  object.scriptId = reader.readString(offsets[6]);
  object.sender = reader.readString(offsets[7]);
  object.threadId = reader.readString(offsets[8]);
  object.type = reader.readString(offsets[9]);
  return object;
}

P _scriptMessageDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readLong(offset)) as P;
    case 3:
      return (reader.readStringOrNull(offset)) as P;
    case 4:
      return (reader.readLong(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readString(offset)) as P;
    case 8:
      return (reader.readString(offset)) as P;
    case 9:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _scriptMessageGetId(ScriptMessage object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _scriptMessageGetLinks(ScriptMessage object) {
  return [];
}

void _scriptMessageAttach(
    IsarCollection<dynamic> col, Id id, ScriptMessage object) {
  object.id = id;
}

extension ScriptMessageByIndex on IsarCollection<ScriptMessage> {
  Future<ScriptMessage?> getByScriptId(String scriptId) {
    return getByIndex(r'scriptId', [scriptId]);
  }

  ScriptMessage? getByScriptIdSync(String scriptId) {
    return getByIndexSync(r'scriptId', [scriptId]);
  }

  Future<bool> deleteByScriptId(String scriptId) {
    return deleteByIndex(r'scriptId', [scriptId]);
  }

  bool deleteByScriptIdSync(String scriptId) {
    return deleteByIndexSync(r'scriptId', [scriptId]);
  }

  Future<List<ScriptMessage?>> getAllByScriptId(List<String> scriptIdValues) {
    final values = scriptIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'scriptId', values);
  }

  List<ScriptMessage?> getAllByScriptIdSync(List<String> scriptIdValues) {
    final values = scriptIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'scriptId', values);
  }

  Future<int> deleteAllByScriptId(List<String> scriptIdValues) {
    final values = scriptIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'scriptId', values);
  }

  int deleteAllByScriptIdSync(List<String> scriptIdValues) {
    final values = scriptIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'scriptId', values);
  }

  Future<Id> putByScriptId(ScriptMessage object) {
    return putByIndex(r'scriptId', object);
  }

  Id putByScriptIdSync(ScriptMessage object, {bool saveLinks = true}) {
    return putByIndexSync(r'scriptId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByScriptId(List<ScriptMessage> objects) {
    return putAllByIndex(r'scriptId', objects);
  }

  List<Id> putAllByScriptIdSync(List<ScriptMessage> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'scriptId', objects, saveLinks: saveLinks);
  }
}

extension ScriptMessageQueryWhereSort
    on QueryBuilder<ScriptMessage, ScriptMessage, QWhere> {
  QueryBuilder<ScriptMessage, ScriptMessage, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension ScriptMessageQueryWhere
    on QueryBuilder<ScriptMessage, ScriptMessage, QWhereClause> {
  QueryBuilder<ScriptMessage, ScriptMessage, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<ScriptMessage, ScriptMessage, QAfterWhereClause> idNotEqualTo(
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

  QueryBuilder<ScriptMessage, ScriptMessage, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<ScriptMessage, ScriptMessage, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<ScriptMessage, ScriptMessage, QAfterWhereClause> idBetween(
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

  QueryBuilder<ScriptMessage, ScriptMessage, QAfterWhereClause> scriptIdEqualTo(
      String scriptId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'scriptId',
        value: [scriptId],
      ));
    });
  }

  QueryBuilder<ScriptMessage, ScriptMessage, QAfterWhereClause>
      scriptIdNotEqualTo(String scriptId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'scriptId',
              lower: [],
              upper: [scriptId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'scriptId',
              lower: [scriptId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'scriptId',
              lower: [scriptId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'scriptId',
              lower: [],
              upper: [scriptId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<ScriptMessage, ScriptMessage, QAfterWhereClause> threadIdEqualTo(
      String threadId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'threadId',
        value: [threadId],
      ));
    });
  }

  QueryBuilder<ScriptMessage, ScriptMessage, QAfterWhereClause>
      threadIdNotEqualTo(String threadId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'threadId',
              lower: [],
              upper: [threadId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'threadId',
              lower: [threadId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'threadId',
              lower: [threadId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'threadId',
              lower: [],
              upper: [threadId],
              includeUpper: false,
            ));
      }
    });
  }
}

extension ScriptMessageQueryFilter
    on QueryBuilder<ScriptMessage, ScriptMessage, QFilterCondition> {
  QueryBuilder<ScriptMessage, ScriptMessage, QAfterFilterCondition>
      choicesJsonIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'choicesJson',
      ));
    });
  }

  QueryBuilder<ScriptMessage, ScriptMessage, QAfterFilterCondition>
      choicesJsonIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'choicesJson',
      ));
    });
  }

  QueryBuilder<ScriptMessage, ScriptMessage, QAfterFilterCondition>
      choicesJsonEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'choicesJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScriptMessage, ScriptMessage, QAfterFilterCondition>
      choicesJsonGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'choicesJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScriptMessage, ScriptMessage, QAfterFilterCondition>
      choicesJsonLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'choicesJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScriptMessage, ScriptMessage, QAfterFilterCondition>
      choicesJsonBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'choicesJson',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScriptMessage, ScriptMessage, QAfterFilterCondition>
      choicesJsonStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'choicesJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScriptMessage, ScriptMessage, QAfterFilterCondition>
      choicesJsonEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'choicesJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScriptMessage, ScriptMessage, QAfterFilterCondition>
      choicesJsonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'choicesJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScriptMessage, ScriptMessage, QAfterFilterCondition>
      choicesJsonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'choicesJson',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScriptMessage, ScriptMessage, QAfterFilterCondition>
      choicesJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'choicesJson',
        value: '',
      ));
    });
  }

  QueryBuilder<ScriptMessage, ScriptMessage, QAfterFilterCondition>
      choicesJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'choicesJson',
        value: '',
      ));
    });
  }

  QueryBuilder<ScriptMessage, ScriptMessage, QAfterFilterCondition>
      contentEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'content',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScriptMessage, ScriptMessage, QAfterFilterCondition>
      contentGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'content',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScriptMessage, ScriptMessage, QAfterFilterCondition>
      contentLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'content',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScriptMessage, ScriptMessage, QAfterFilterCondition>
      contentBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'content',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScriptMessage, ScriptMessage, QAfterFilterCondition>
      contentStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'content',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScriptMessage, ScriptMessage, QAfterFilterCondition>
      contentEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'content',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScriptMessage, ScriptMessage, QAfterFilterCondition>
      contentContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'content',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScriptMessage, ScriptMessage, QAfterFilterCondition>
      contentMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'content',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScriptMessage, ScriptMessage, QAfterFilterCondition>
      contentIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'content',
        value: '',
      ));
    });
  }

  QueryBuilder<ScriptMessage, ScriptMessage, QAfterFilterCondition>
      contentIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'content',
        value: '',
      ));
    });
  }

  QueryBuilder<ScriptMessage, ScriptMessage, QAfterFilterCondition>
      delayEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'delay',
        value: value,
      ));
    });
  }

  QueryBuilder<ScriptMessage, ScriptMessage, QAfterFilterCondition>
      delayGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'delay',
        value: value,
      ));
    });
  }

  QueryBuilder<ScriptMessage, ScriptMessage, QAfterFilterCondition>
      delayLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'delay',
        value: value,
      ));
    });
  }

  QueryBuilder<ScriptMessage, ScriptMessage, QAfterFilterCondition>
      delayBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'delay',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ScriptMessage, ScriptMessage, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<ScriptMessage, ScriptMessage, QAfterFilterCondition>
      idGreaterThan(
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

  QueryBuilder<ScriptMessage, ScriptMessage, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<ScriptMessage, ScriptMessage, QAfterFilterCondition> idBetween(
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

  QueryBuilder<ScriptMessage, ScriptMessage, QAfterFilterCondition>
      metadataJsonIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'metadataJson',
      ));
    });
  }

  QueryBuilder<ScriptMessage, ScriptMessage, QAfterFilterCondition>
      metadataJsonIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'metadataJson',
      ));
    });
  }

  QueryBuilder<ScriptMessage, ScriptMessage, QAfterFilterCondition>
      metadataJsonEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'metadataJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScriptMessage, ScriptMessage, QAfterFilterCondition>
      metadataJsonGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'metadataJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScriptMessage, ScriptMessage, QAfterFilterCondition>
      metadataJsonLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'metadataJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScriptMessage, ScriptMessage, QAfterFilterCondition>
      metadataJsonBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'metadataJson',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScriptMessage, ScriptMessage, QAfterFilterCondition>
      metadataJsonStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'metadataJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScriptMessage, ScriptMessage, QAfterFilterCondition>
      metadataJsonEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'metadataJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScriptMessage, ScriptMessage, QAfterFilterCondition>
      metadataJsonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'metadataJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScriptMessage, ScriptMessage, QAfterFilterCondition>
      metadataJsonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'metadataJson',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScriptMessage, ScriptMessage, QAfterFilterCondition>
      metadataJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'metadataJson',
        value: '',
      ));
    });
  }

  QueryBuilder<ScriptMessage, ScriptMessage, QAfterFilterCondition>
      metadataJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'metadataJson',
        value: '',
      ));
    });
  }

  QueryBuilder<ScriptMessage, ScriptMessage, QAfterFilterCondition>
      orderIndexEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'orderIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<ScriptMessage, ScriptMessage, QAfterFilterCondition>
      orderIndexGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'orderIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<ScriptMessage, ScriptMessage, QAfterFilterCondition>
      orderIndexLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'orderIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<ScriptMessage, ScriptMessage, QAfterFilterCondition>
      orderIndexBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'orderIndex',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ScriptMessage, ScriptMessage, QAfterFilterCondition>
      sceneIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sceneId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScriptMessage, ScriptMessage, QAfterFilterCondition>
      sceneIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'sceneId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScriptMessage, ScriptMessage, QAfterFilterCondition>
      sceneIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'sceneId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScriptMessage, ScriptMessage, QAfterFilterCondition>
      sceneIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'sceneId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScriptMessage, ScriptMessage, QAfterFilterCondition>
      sceneIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'sceneId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScriptMessage, ScriptMessage, QAfterFilterCondition>
      sceneIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'sceneId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScriptMessage, ScriptMessage, QAfterFilterCondition>
      sceneIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'sceneId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScriptMessage, ScriptMessage, QAfterFilterCondition>
      sceneIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'sceneId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScriptMessage, ScriptMessage, QAfterFilterCondition>
      sceneIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sceneId',
        value: '',
      ));
    });
  }

  QueryBuilder<ScriptMessage, ScriptMessage, QAfterFilterCondition>
      sceneIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'sceneId',
        value: '',
      ));
    });
  }

  QueryBuilder<ScriptMessage, ScriptMessage, QAfterFilterCondition>
      scriptIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'scriptId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScriptMessage, ScriptMessage, QAfterFilterCondition>
      scriptIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'scriptId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScriptMessage, ScriptMessage, QAfterFilterCondition>
      scriptIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'scriptId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScriptMessage, ScriptMessage, QAfterFilterCondition>
      scriptIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'scriptId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScriptMessage, ScriptMessage, QAfterFilterCondition>
      scriptIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'scriptId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScriptMessage, ScriptMessage, QAfterFilterCondition>
      scriptIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'scriptId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScriptMessage, ScriptMessage, QAfterFilterCondition>
      scriptIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'scriptId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScriptMessage, ScriptMessage, QAfterFilterCondition>
      scriptIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'scriptId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScriptMessage, ScriptMessage, QAfterFilterCondition>
      scriptIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'scriptId',
        value: '',
      ));
    });
  }

  QueryBuilder<ScriptMessage, ScriptMessage, QAfterFilterCondition>
      scriptIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'scriptId',
        value: '',
      ));
    });
  }

  QueryBuilder<ScriptMessage, ScriptMessage, QAfterFilterCondition>
      senderEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sender',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScriptMessage, ScriptMessage, QAfterFilterCondition>
      senderGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'sender',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScriptMessage, ScriptMessage, QAfterFilterCondition>
      senderLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'sender',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScriptMessage, ScriptMessage, QAfterFilterCondition>
      senderBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'sender',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScriptMessage, ScriptMessage, QAfterFilterCondition>
      senderStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'sender',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScriptMessage, ScriptMessage, QAfterFilterCondition>
      senderEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'sender',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScriptMessage, ScriptMessage, QAfterFilterCondition>
      senderContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'sender',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScriptMessage, ScriptMessage, QAfterFilterCondition>
      senderMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'sender',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScriptMessage, ScriptMessage, QAfterFilterCondition>
      senderIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sender',
        value: '',
      ));
    });
  }

  QueryBuilder<ScriptMessage, ScriptMessage, QAfterFilterCondition>
      senderIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'sender',
        value: '',
      ));
    });
  }

  QueryBuilder<ScriptMessage, ScriptMessage, QAfterFilterCondition>
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

  QueryBuilder<ScriptMessage, ScriptMessage, QAfterFilterCondition>
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

  QueryBuilder<ScriptMessage, ScriptMessage, QAfterFilterCondition>
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

  QueryBuilder<ScriptMessage, ScriptMessage, QAfterFilterCondition>
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

  QueryBuilder<ScriptMessage, ScriptMessage, QAfterFilterCondition>
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

  QueryBuilder<ScriptMessage, ScriptMessage, QAfterFilterCondition>
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

  QueryBuilder<ScriptMessage, ScriptMessage, QAfterFilterCondition>
      threadIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'threadId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScriptMessage, ScriptMessage, QAfterFilterCondition>
      threadIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'threadId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScriptMessage, ScriptMessage, QAfterFilterCondition>
      threadIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'threadId',
        value: '',
      ));
    });
  }

  QueryBuilder<ScriptMessage, ScriptMessage, QAfterFilterCondition>
      threadIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'threadId',
        value: '',
      ));
    });
  }

  QueryBuilder<ScriptMessage, ScriptMessage, QAfterFilterCondition> typeEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'type',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScriptMessage, ScriptMessage, QAfterFilterCondition>
      typeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'type',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScriptMessage, ScriptMessage, QAfterFilterCondition>
      typeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'type',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScriptMessage, ScriptMessage, QAfterFilterCondition> typeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'type',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScriptMessage, ScriptMessage, QAfterFilterCondition>
      typeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'type',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScriptMessage, ScriptMessage, QAfterFilterCondition>
      typeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'type',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScriptMessage, ScriptMessage, QAfterFilterCondition>
      typeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'type',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScriptMessage, ScriptMessage, QAfterFilterCondition> typeMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'type',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScriptMessage, ScriptMessage, QAfterFilterCondition>
      typeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'type',
        value: '',
      ));
    });
  }

  QueryBuilder<ScriptMessage, ScriptMessage, QAfterFilterCondition>
      typeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'type',
        value: '',
      ));
    });
  }
}

extension ScriptMessageQueryObject
    on QueryBuilder<ScriptMessage, ScriptMessage, QFilterCondition> {}

extension ScriptMessageQueryLinks
    on QueryBuilder<ScriptMessage, ScriptMessage, QFilterCondition> {}

extension ScriptMessageQuerySortBy
    on QueryBuilder<ScriptMessage, ScriptMessage, QSortBy> {
  QueryBuilder<ScriptMessage, ScriptMessage, QAfterSortBy> sortByChoicesJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'choicesJson', Sort.asc);
    });
  }

  QueryBuilder<ScriptMessage, ScriptMessage, QAfterSortBy>
      sortByChoicesJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'choicesJson', Sort.desc);
    });
  }

  QueryBuilder<ScriptMessage, ScriptMessage, QAfterSortBy> sortByContent() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'content', Sort.asc);
    });
  }

  QueryBuilder<ScriptMessage, ScriptMessage, QAfterSortBy> sortByContentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'content', Sort.desc);
    });
  }

  QueryBuilder<ScriptMessage, ScriptMessage, QAfterSortBy> sortByDelay() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'delay', Sort.asc);
    });
  }

  QueryBuilder<ScriptMessage, ScriptMessage, QAfterSortBy> sortByDelayDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'delay', Sort.desc);
    });
  }

  QueryBuilder<ScriptMessage, ScriptMessage, QAfterSortBy>
      sortByMetadataJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'metadataJson', Sort.asc);
    });
  }

  QueryBuilder<ScriptMessage, ScriptMessage, QAfterSortBy>
      sortByMetadataJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'metadataJson', Sort.desc);
    });
  }

  QueryBuilder<ScriptMessage, ScriptMessage, QAfterSortBy> sortByOrderIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'orderIndex', Sort.asc);
    });
  }

  QueryBuilder<ScriptMessage, ScriptMessage, QAfterSortBy>
      sortByOrderIndexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'orderIndex', Sort.desc);
    });
  }

  QueryBuilder<ScriptMessage, ScriptMessage, QAfterSortBy> sortBySceneId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sceneId', Sort.asc);
    });
  }

  QueryBuilder<ScriptMessage, ScriptMessage, QAfterSortBy> sortBySceneIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sceneId', Sort.desc);
    });
  }

  QueryBuilder<ScriptMessage, ScriptMessage, QAfterSortBy> sortByScriptId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scriptId', Sort.asc);
    });
  }

  QueryBuilder<ScriptMessage, ScriptMessage, QAfterSortBy>
      sortByScriptIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scriptId', Sort.desc);
    });
  }

  QueryBuilder<ScriptMessage, ScriptMessage, QAfterSortBy> sortBySender() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sender', Sort.asc);
    });
  }

  QueryBuilder<ScriptMessage, ScriptMessage, QAfterSortBy> sortBySenderDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sender', Sort.desc);
    });
  }

  QueryBuilder<ScriptMessage, ScriptMessage, QAfterSortBy> sortByThreadId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'threadId', Sort.asc);
    });
  }

  QueryBuilder<ScriptMessage, ScriptMessage, QAfterSortBy>
      sortByThreadIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'threadId', Sort.desc);
    });
  }

  QueryBuilder<ScriptMessage, ScriptMessage, QAfterSortBy> sortByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.asc);
    });
  }

  QueryBuilder<ScriptMessage, ScriptMessage, QAfterSortBy> sortByTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.desc);
    });
  }
}

extension ScriptMessageQuerySortThenBy
    on QueryBuilder<ScriptMessage, ScriptMessage, QSortThenBy> {
  QueryBuilder<ScriptMessage, ScriptMessage, QAfterSortBy> thenByChoicesJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'choicesJson', Sort.asc);
    });
  }

  QueryBuilder<ScriptMessage, ScriptMessage, QAfterSortBy>
      thenByChoicesJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'choicesJson', Sort.desc);
    });
  }

  QueryBuilder<ScriptMessage, ScriptMessage, QAfterSortBy> thenByContent() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'content', Sort.asc);
    });
  }

  QueryBuilder<ScriptMessage, ScriptMessage, QAfterSortBy> thenByContentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'content', Sort.desc);
    });
  }

  QueryBuilder<ScriptMessage, ScriptMessage, QAfterSortBy> thenByDelay() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'delay', Sort.asc);
    });
  }

  QueryBuilder<ScriptMessage, ScriptMessage, QAfterSortBy> thenByDelayDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'delay', Sort.desc);
    });
  }

  QueryBuilder<ScriptMessage, ScriptMessage, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<ScriptMessage, ScriptMessage, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<ScriptMessage, ScriptMessage, QAfterSortBy>
      thenByMetadataJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'metadataJson', Sort.asc);
    });
  }

  QueryBuilder<ScriptMessage, ScriptMessage, QAfterSortBy>
      thenByMetadataJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'metadataJson', Sort.desc);
    });
  }

  QueryBuilder<ScriptMessage, ScriptMessage, QAfterSortBy> thenByOrderIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'orderIndex', Sort.asc);
    });
  }

  QueryBuilder<ScriptMessage, ScriptMessage, QAfterSortBy>
      thenByOrderIndexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'orderIndex', Sort.desc);
    });
  }

  QueryBuilder<ScriptMessage, ScriptMessage, QAfterSortBy> thenBySceneId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sceneId', Sort.asc);
    });
  }

  QueryBuilder<ScriptMessage, ScriptMessage, QAfterSortBy> thenBySceneIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sceneId', Sort.desc);
    });
  }

  QueryBuilder<ScriptMessage, ScriptMessage, QAfterSortBy> thenByScriptId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scriptId', Sort.asc);
    });
  }

  QueryBuilder<ScriptMessage, ScriptMessage, QAfterSortBy>
      thenByScriptIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scriptId', Sort.desc);
    });
  }

  QueryBuilder<ScriptMessage, ScriptMessage, QAfterSortBy> thenBySender() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sender', Sort.asc);
    });
  }

  QueryBuilder<ScriptMessage, ScriptMessage, QAfterSortBy> thenBySenderDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sender', Sort.desc);
    });
  }

  QueryBuilder<ScriptMessage, ScriptMessage, QAfterSortBy> thenByThreadId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'threadId', Sort.asc);
    });
  }

  QueryBuilder<ScriptMessage, ScriptMessage, QAfterSortBy>
      thenByThreadIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'threadId', Sort.desc);
    });
  }

  QueryBuilder<ScriptMessage, ScriptMessage, QAfterSortBy> thenByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.asc);
    });
  }

  QueryBuilder<ScriptMessage, ScriptMessage, QAfterSortBy> thenByTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.desc);
    });
  }
}

extension ScriptMessageQueryWhereDistinct
    on QueryBuilder<ScriptMessage, ScriptMessage, QDistinct> {
  QueryBuilder<ScriptMessage, ScriptMessage, QDistinct> distinctByChoicesJson(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'choicesJson', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ScriptMessage, ScriptMessage, QDistinct> distinctByContent(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'content', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ScriptMessage, ScriptMessage, QDistinct> distinctByDelay() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'delay');
    });
  }

  QueryBuilder<ScriptMessage, ScriptMessage, QDistinct> distinctByMetadataJson(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'metadataJson', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ScriptMessage, ScriptMessage, QDistinct> distinctByOrderIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'orderIndex');
    });
  }

  QueryBuilder<ScriptMessage, ScriptMessage, QDistinct> distinctBySceneId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sceneId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ScriptMessage, ScriptMessage, QDistinct> distinctByScriptId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'scriptId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ScriptMessage, ScriptMessage, QDistinct> distinctBySender(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sender', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ScriptMessage, ScriptMessage, QDistinct> distinctByThreadId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'threadId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ScriptMessage, ScriptMessage, QDistinct> distinctByType(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'type', caseSensitive: caseSensitive);
    });
  }
}

extension ScriptMessageQueryProperty
    on QueryBuilder<ScriptMessage, ScriptMessage, QQueryProperty> {
  QueryBuilder<ScriptMessage, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<ScriptMessage, String?, QQueryOperations> choicesJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'choicesJson');
    });
  }

  QueryBuilder<ScriptMessage, String, QQueryOperations> contentProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'content');
    });
  }

  QueryBuilder<ScriptMessage, int, QQueryOperations> delayProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'delay');
    });
  }

  QueryBuilder<ScriptMessage, String?, QQueryOperations>
      metadataJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'metadataJson');
    });
  }

  QueryBuilder<ScriptMessage, int, QQueryOperations> orderIndexProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'orderIndex');
    });
  }

  QueryBuilder<ScriptMessage, String, QQueryOperations> sceneIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sceneId');
    });
  }

  QueryBuilder<ScriptMessage, String, QQueryOperations> scriptIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'scriptId');
    });
  }

  QueryBuilder<ScriptMessage, String, QQueryOperations> senderProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sender');
    });
  }

  QueryBuilder<ScriptMessage, String, QQueryOperations> threadIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'threadId');
    });
  }

  QueryBuilder<ScriptMessage, String, QQueryOperations> typeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'type');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetThreadMetaCollection on Isar {
  IsarCollection<ThreadMeta> get threadMetas => this.collection();
}

const ThreadMetaSchema = CollectionSchema(
  name: r'ThreadMeta',
  id: 6692205570371020660,
  properties: {
    r'app': PropertySchema(
      id: 0,
      name: r'app',
      type: IsarType.string,
    ),
    r'characterId': PropertySchema(
      id: 1,
      name: r'characterId',
      type: IsarType.string,
    ),
    r'threadId': PropertySchema(
      id: 2,
      name: r'threadId',
      type: IsarType.string,
    ),
    r'unlockRuleJson': PropertySchema(
      id: 3,
      name: r'unlockRuleJson',
      type: IsarType.string,
    )
  },
  estimateSize: _threadMetaEstimateSize,
  serialize: _threadMetaSerialize,
  deserialize: _threadMetaDeserialize,
  deserializeProp: _threadMetaDeserializeProp,
  idName: r'id',
  indexes: {
    r'threadId': IndexSchema(
      id: -1397508362477071783,
      name: r'threadId',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'threadId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _threadMetaGetId,
  getLinks: _threadMetaGetLinks,
  attach: _threadMetaAttach,
  version: '3.1.0+1',
);

int _threadMetaEstimateSize(
  ThreadMeta object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.app.length * 3;
  bytesCount += 3 + object.characterId.length * 3;
  bytesCount += 3 + object.threadId.length * 3;
  {
    final value = object.unlockRuleJson;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _threadMetaSerialize(
  ThreadMeta object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.app);
  writer.writeString(offsets[1], object.characterId);
  writer.writeString(offsets[2], object.threadId);
  writer.writeString(offsets[3], object.unlockRuleJson);
}

ThreadMeta _threadMetaDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = ThreadMeta();
  object.app = reader.readString(offsets[0]);
  object.characterId = reader.readString(offsets[1]);
  object.id = id;
  object.threadId = reader.readString(offsets[2]);
  object.unlockRuleJson = reader.readStringOrNull(offsets[3]);
  return object;
}

P _threadMetaDeserializeProp<P>(
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
      return (reader.readStringOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _threadMetaGetId(ThreadMeta object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _threadMetaGetLinks(ThreadMeta object) {
  return [];
}

void _threadMetaAttach(IsarCollection<dynamic> col, Id id, ThreadMeta object) {
  object.id = id;
}

extension ThreadMetaByIndex on IsarCollection<ThreadMeta> {
  Future<ThreadMeta?> getByThreadId(String threadId) {
    return getByIndex(r'threadId', [threadId]);
  }

  ThreadMeta? getByThreadIdSync(String threadId) {
    return getByIndexSync(r'threadId', [threadId]);
  }

  Future<bool> deleteByThreadId(String threadId) {
    return deleteByIndex(r'threadId', [threadId]);
  }

  bool deleteByThreadIdSync(String threadId) {
    return deleteByIndexSync(r'threadId', [threadId]);
  }

  Future<List<ThreadMeta?>> getAllByThreadId(List<String> threadIdValues) {
    final values = threadIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'threadId', values);
  }

  List<ThreadMeta?> getAllByThreadIdSync(List<String> threadIdValues) {
    final values = threadIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'threadId', values);
  }

  Future<int> deleteAllByThreadId(List<String> threadIdValues) {
    final values = threadIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'threadId', values);
  }

  int deleteAllByThreadIdSync(List<String> threadIdValues) {
    final values = threadIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'threadId', values);
  }

  Future<Id> putByThreadId(ThreadMeta object) {
    return putByIndex(r'threadId', object);
  }

  Id putByThreadIdSync(ThreadMeta object, {bool saveLinks = true}) {
    return putByIndexSync(r'threadId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByThreadId(List<ThreadMeta> objects) {
    return putAllByIndex(r'threadId', objects);
  }

  List<Id> putAllByThreadIdSync(List<ThreadMeta> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'threadId', objects, saveLinks: saveLinks);
  }
}

extension ThreadMetaQueryWhereSort
    on QueryBuilder<ThreadMeta, ThreadMeta, QWhere> {
  QueryBuilder<ThreadMeta, ThreadMeta, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension ThreadMetaQueryWhere
    on QueryBuilder<ThreadMeta, ThreadMeta, QWhereClause> {
  QueryBuilder<ThreadMeta, ThreadMeta, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<ThreadMeta, ThreadMeta, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<ThreadMeta, ThreadMeta, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<ThreadMeta, ThreadMeta, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<ThreadMeta, ThreadMeta, QAfterWhereClause> idBetween(
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

  QueryBuilder<ThreadMeta, ThreadMeta, QAfterWhereClause> threadIdEqualTo(
      String threadId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'threadId',
        value: [threadId],
      ));
    });
  }

  QueryBuilder<ThreadMeta, ThreadMeta, QAfterWhereClause> threadIdNotEqualTo(
      String threadId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'threadId',
              lower: [],
              upper: [threadId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'threadId',
              lower: [threadId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'threadId',
              lower: [threadId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'threadId',
              lower: [],
              upper: [threadId],
              includeUpper: false,
            ));
      }
    });
  }
}

extension ThreadMetaQueryFilter
    on QueryBuilder<ThreadMeta, ThreadMeta, QFilterCondition> {
  QueryBuilder<ThreadMeta, ThreadMeta, QAfterFilterCondition> appEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'app',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ThreadMeta, ThreadMeta, QAfterFilterCondition> appGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'app',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ThreadMeta, ThreadMeta, QAfterFilterCondition> appLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'app',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ThreadMeta, ThreadMeta, QAfterFilterCondition> appBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'app',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ThreadMeta, ThreadMeta, QAfterFilterCondition> appStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'app',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ThreadMeta, ThreadMeta, QAfterFilterCondition> appEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'app',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ThreadMeta, ThreadMeta, QAfterFilterCondition> appContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'app',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ThreadMeta, ThreadMeta, QAfterFilterCondition> appMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'app',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ThreadMeta, ThreadMeta, QAfterFilterCondition> appIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'app',
        value: '',
      ));
    });
  }

  QueryBuilder<ThreadMeta, ThreadMeta, QAfterFilterCondition> appIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'app',
        value: '',
      ));
    });
  }

  QueryBuilder<ThreadMeta, ThreadMeta, QAfterFilterCondition>
      characterIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'characterId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ThreadMeta, ThreadMeta, QAfterFilterCondition>
      characterIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'characterId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ThreadMeta, ThreadMeta, QAfterFilterCondition>
      characterIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'characterId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ThreadMeta, ThreadMeta, QAfterFilterCondition>
      characterIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'characterId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ThreadMeta, ThreadMeta, QAfterFilterCondition>
      characterIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'characterId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ThreadMeta, ThreadMeta, QAfterFilterCondition>
      characterIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'characterId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ThreadMeta, ThreadMeta, QAfterFilterCondition>
      characterIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'characterId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ThreadMeta, ThreadMeta, QAfterFilterCondition>
      characterIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'characterId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ThreadMeta, ThreadMeta, QAfterFilterCondition>
      characterIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'characterId',
        value: '',
      ));
    });
  }

  QueryBuilder<ThreadMeta, ThreadMeta, QAfterFilterCondition>
      characterIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'characterId',
        value: '',
      ));
    });
  }

  QueryBuilder<ThreadMeta, ThreadMeta, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<ThreadMeta, ThreadMeta, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<ThreadMeta, ThreadMeta, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<ThreadMeta, ThreadMeta, QAfterFilterCondition> idBetween(
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

  QueryBuilder<ThreadMeta, ThreadMeta, QAfterFilterCondition> threadIdEqualTo(
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

  QueryBuilder<ThreadMeta, ThreadMeta, QAfterFilterCondition>
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

  QueryBuilder<ThreadMeta, ThreadMeta, QAfterFilterCondition> threadIdLessThan(
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

  QueryBuilder<ThreadMeta, ThreadMeta, QAfterFilterCondition> threadIdBetween(
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

  QueryBuilder<ThreadMeta, ThreadMeta, QAfterFilterCondition>
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

  QueryBuilder<ThreadMeta, ThreadMeta, QAfterFilterCondition> threadIdEndsWith(
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

  QueryBuilder<ThreadMeta, ThreadMeta, QAfterFilterCondition> threadIdContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'threadId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ThreadMeta, ThreadMeta, QAfterFilterCondition> threadIdMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'threadId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ThreadMeta, ThreadMeta, QAfterFilterCondition>
      threadIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'threadId',
        value: '',
      ));
    });
  }

  QueryBuilder<ThreadMeta, ThreadMeta, QAfterFilterCondition>
      threadIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'threadId',
        value: '',
      ));
    });
  }

  QueryBuilder<ThreadMeta, ThreadMeta, QAfterFilterCondition>
      unlockRuleJsonIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'unlockRuleJson',
      ));
    });
  }

  QueryBuilder<ThreadMeta, ThreadMeta, QAfterFilterCondition>
      unlockRuleJsonIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'unlockRuleJson',
      ));
    });
  }

  QueryBuilder<ThreadMeta, ThreadMeta, QAfterFilterCondition>
      unlockRuleJsonEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'unlockRuleJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ThreadMeta, ThreadMeta, QAfterFilterCondition>
      unlockRuleJsonGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'unlockRuleJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ThreadMeta, ThreadMeta, QAfterFilterCondition>
      unlockRuleJsonLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'unlockRuleJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ThreadMeta, ThreadMeta, QAfterFilterCondition>
      unlockRuleJsonBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'unlockRuleJson',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ThreadMeta, ThreadMeta, QAfterFilterCondition>
      unlockRuleJsonStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'unlockRuleJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ThreadMeta, ThreadMeta, QAfterFilterCondition>
      unlockRuleJsonEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'unlockRuleJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ThreadMeta, ThreadMeta, QAfterFilterCondition>
      unlockRuleJsonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'unlockRuleJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ThreadMeta, ThreadMeta, QAfterFilterCondition>
      unlockRuleJsonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'unlockRuleJson',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ThreadMeta, ThreadMeta, QAfterFilterCondition>
      unlockRuleJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'unlockRuleJson',
        value: '',
      ));
    });
  }

  QueryBuilder<ThreadMeta, ThreadMeta, QAfterFilterCondition>
      unlockRuleJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'unlockRuleJson',
        value: '',
      ));
    });
  }
}

extension ThreadMetaQueryObject
    on QueryBuilder<ThreadMeta, ThreadMeta, QFilterCondition> {}

extension ThreadMetaQueryLinks
    on QueryBuilder<ThreadMeta, ThreadMeta, QFilterCondition> {}

extension ThreadMetaQuerySortBy
    on QueryBuilder<ThreadMeta, ThreadMeta, QSortBy> {
  QueryBuilder<ThreadMeta, ThreadMeta, QAfterSortBy> sortByApp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'app', Sort.asc);
    });
  }

  QueryBuilder<ThreadMeta, ThreadMeta, QAfterSortBy> sortByAppDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'app', Sort.desc);
    });
  }

  QueryBuilder<ThreadMeta, ThreadMeta, QAfterSortBy> sortByCharacterId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'characterId', Sort.asc);
    });
  }

  QueryBuilder<ThreadMeta, ThreadMeta, QAfterSortBy> sortByCharacterIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'characterId', Sort.desc);
    });
  }

  QueryBuilder<ThreadMeta, ThreadMeta, QAfterSortBy> sortByThreadId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'threadId', Sort.asc);
    });
  }

  QueryBuilder<ThreadMeta, ThreadMeta, QAfterSortBy> sortByThreadIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'threadId', Sort.desc);
    });
  }

  QueryBuilder<ThreadMeta, ThreadMeta, QAfterSortBy> sortByUnlockRuleJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unlockRuleJson', Sort.asc);
    });
  }

  QueryBuilder<ThreadMeta, ThreadMeta, QAfterSortBy>
      sortByUnlockRuleJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unlockRuleJson', Sort.desc);
    });
  }
}

extension ThreadMetaQuerySortThenBy
    on QueryBuilder<ThreadMeta, ThreadMeta, QSortThenBy> {
  QueryBuilder<ThreadMeta, ThreadMeta, QAfterSortBy> thenByApp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'app', Sort.asc);
    });
  }

  QueryBuilder<ThreadMeta, ThreadMeta, QAfterSortBy> thenByAppDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'app', Sort.desc);
    });
  }

  QueryBuilder<ThreadMeta, ThreadMeta, QAfterSortBy> thenByCharacterId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'characterId', Sort.asc);
    });
  }

  QueryBuilder<ThreadMeta, ThreadMeta, QAfterSortBy> thenByCharacterIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'characterId', Sort.desc);
    });
  }

  QueryBuilder<ThreadMeta, ThreadMeta, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<ThreadMeta, ThreadMeta, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<ThreadMeta, ThreadMeta, QAfterSortBy> thenByThreadId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'threadId', Sort.asc);
    });
  }

  QueryBuilder<ThreadMeta, ThreadMeta, QAfterSortBy> thenByThreadIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'threadId', Sort.desc);
    });
  }

  QueryBuilder<ThreadMeta, ThreadMeta, QAfterSortBy> thenByUnlockRuleJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unlockRuleJson', Sort.asc);
    });
  }

  QueryBuilder<ThreadMeta, ThreadMeta, QAfterSortBy>
      thenByUnlockRuleJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unlockRuleJson', Sort.desc);
    });
  }
}

extension ThreadMetaQueryWhereDistinct
    on QueryBuilder<ThreadMeta, ThreadMeta, QDistinct> {
  QueryBuilder<ThreadMeta, ThreadMeta, QDistinct> distinctByApp(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'app', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ThreadMeta, ThreadMeta, QDistinct> distinctByCharacterId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'characterId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ThreadMeta, ThreadMeta, QDistinct> distinctByThreadId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'threadId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ThreadMeta, ThreadMeta, QDistinct> distinctByUnlockRuleJson(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'unlockRuleJson',
          caseSensitive: caseSensitive);
    });
  }
}

extension ThreadMetaQueryProperty
    on QueryBuilder<ThreadMeta, ThreadMeta, QQueryProperty> {
  QueryBuilder<ThreadMeta, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<ThreadMeta, String, QQueryOperations> appProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'app');
    });
  }

  QueryBuilder<ThreadMeta, String, QQueryOperations> characterIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'characterId');
    });
  }

  QueryBuilder<ThreadMeta, String, QQueryOperations> threadIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'threadId');
    });
  }

  QueryBuilder<ThreadMeta, String?, QQueryOperations> unlockRuleJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'unlockRuleJson');
    });
  }
}
