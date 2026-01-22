// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'playback_models.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetVisibleMessageCollection on Isar {
  IsarCollection<VisibleMessage> get visibleMessages => this.collection();
}

const VisibleMessageSchema = CollectionSchema(
  name: r'VisibleMessage',
  id: 3974516003372042474,
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
    r'deliveredAt': PropertySchema(
      id: 2,
      name: r'deliveredAt',
      type: IsarType.dateTime,
    ),
    r'origin': PropertySchema(
      id: 3,
      name: r'origin',
      type: IsarType.string,
    ),
    r'saveSlotId': PropertySchema(
      id: 4,
      name: r'saveSlotId',
      type: IsarType.string,
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
  estimateSize: _visibleMessageEstimateSize,
  serialize: _visibleMessageSerialize,
  deserialize: _visibleMessageDeserialize,
  deserializeProp: _visibleMessageDeserializeProp,
  idName: r'id',
  indexes: {
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
    ),
    r'origin': IndexSchema(
      id: 2956397086907132908,
      name: r'origin',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'origin',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _visibleMessageGetId,
  getLinks: _visibleMessageGetLinks,
  attach: _visibleMessageAttach,
  version: '3.1.0+1',
);

int _visibleMessageEstimateSize(
  VisibleMessage object,
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
  bytesCount += 3 + object.origin.length * 3;
  bytesCount += 3 + object.saveSlotId.length * 3;
  {
    final value = object.sceneId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.scriptId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.sender.length * 3;
  bytesCount += 3 + object.threadId.length * 3;
  bytesCount += 3 + object.type.length * 3;
  return bytesCount;
}

void _visibleMessageSerialize(
  VisibleMessage object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.choicesJson);
  writer.writeString(offsets[1], object.content);
  writer.writeDateTime(offsets[2], object.deliveredAt);
  writer.writeString(offsets[3], object.origin);
  writer.writeString(offsets[4], object.saveSlotId);
  writer.writeString(offsets[5], object.sceneId);
  writer.writeString(offsets[6], object.scriptId);
  writer.writeString(offsets[7], object.sender);
  writer.writeString(offsets[8], object.threadId);
  writer.writeString(offsets[9], object.type);
}

VisibleMessage _visibleMessageDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = VisibleMessage();
  object.choicesJson = reader.readStringOrNull(offsets[0]);
  object.content = reader.readString(offsets[1]);
  object.deliveredAt = reader.readDateTime(offsets[2]);
  object.id = id;
  object.origin = reader.readString(offsets[3]);
  object.saveSlotId = reader.readString(offsets[4]);
  object.sceneId = reader.readStringOrNull(offsets[5]);
  object.scriptId = reader.readStringOrNull(offsets[6]);
  object.sender = reader.readString(offsets[7]);
  object.threadId = reader.readString(offsets[8]);
  object.type = reader.readString(offsets[9]);
  return object;
}

P _visibleMessageDeserializeProp<P>(
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
      return (reader.readDateTime(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readStringOrNull(offset)) as P;
    case 6:
      return (reader.readStringOrNull(offset)) as P;
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

Id _visibleMessageGetId(VisibleMessage object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _visibleMessageGetLinks(VisibleMessage object) {
  return [];
}

void _visibleMessageAttach(
    IsarCollection<dynamic> col, Id id, VisibleMessage object) {
  object.id = id;
}

extension VisibleMessageQueryWhereSort
    on QueryBuilder<VisibleMessage, VisibleMessage, QWhere> {
  QueryBuilder<VisibleMessage, VisibleMessage, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension VisibleMessageQueryWhere
    on QueryBuilder<VisibleMessage, VisibleMessage, QWhereClause> {
  QueryBuilder<VisibleMessage, VisibleMessage, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<VisibleMessage, VisibleMessage, QAfterWhereClause> idNotEqualTo(
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

  QueryBuilder<VisibleMessage, VisibleMessage, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<VisibleMessage, VisibleMessage, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<VisibleMessage, VisibleMessage, QAfterWhereClause> idBetween(
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

  QueryBuilder<VisibleMessage, VisibleMessage, QAfterWhereClause>
      threadIdEqualTo(String threadId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'threadId',
        value: [threadId],
      ));
    });
  }

  QueryBuilder<VisibleMessage, VisibleMessage, QAfterWhereClause>
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

  QueryBuilder<VisibleMessage, VisibleMessage, QAfterWhereClause> originEqualTo(
      String origin) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'origin',
        value: [origin],
      ));
    });
  }

  QueryBuilder<VisibleMessage, VisibleMessage, QAfterWhereClause>
      originNotEqualTo(String origin) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'origin',
              lower: [],
              upper: [origin],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'origin',
              lower: [origin],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'origin',
              lower: [origin],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'origin',
              lower: [],
              upper: [origin],
              includeUpper: false,
            ));
      }
    });
  }
}

extension VisibleMessageQueryFilter
    on QueryBuilder<VisibleMessage, VisibleMessage, QFilterCondition> {
  QueryBuilder<VisibleMessage, VisibleMessage, QAfterFilterCondition>
      choicesJsonIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'choicesJson',
      ));
    });
  }

  QueryBuilder<VisibleMessage, VisibleMessage, QAfterFilterCondition>
      choicesJsonIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'choicesJson',
      ));
    });
  }

  QueryBuilder<VisibleMessage, VisibleMessage, QAfterFilterCondition>
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

  QueryBuilder<VisibleMessage, VisibleMessage, QAfterFilterCondition>
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

  QueryBuilder<VisibleMessage, VisibleMessage, QAfterFilterCondition>
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

  QueryBuilder<VisibleMessage, VisibleMessage, QAfterFilterCondition>
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

  QueryBuilder<VisibleMessage, VisibleMessage, QAfterFilterCondition>
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

  QueryBuilder<VisibleMessage, VisibleMessage, QAfterFilterCondition>
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

  QueryBuilder<VisibleMessage, VisibleMessage, QAfterFilterCondition>
      choicesJsonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'choicesJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisibleMessage, VisibleMessage, QAfterFilterCondition>
      choicesJsonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'choicesJson',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisibleMessage, VisibleMessage, QAfterFilterCondition>
      choicesJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'choicesJson',
        value: '',
      ));
    });
  }

  QueryBuilder<VisibleMessage, VisibleMessage, QAfterFilterCondition>
      choicesJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'choicesJson',
        value: '',
      ));
    });
  }

  QueryBuilder<VisibleMessage, VisibleMessage, QAfterFilterCondition>
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

  QueryBuilder<VisibleMessage, VisibleMessage, QAfterFilterCondition>
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

  QueryBuilder<VisibleMessage, VisibleMessage, QAfterFilterCondition>
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

  QueryBuilder<VisibleMessage, VisibleMessage, QAfterFilterCondition>
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

  QueryBuilder<VisibleMessage, VisibleMessage, QAfterFilterCondition>
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

  QueryBuilder<VisibleMessage, VisibleMessage, QAfterFilterCondition>
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

  QueryBuilder<VisibleMessage, VisibleMessage, QAfterFilterCondition>
      contentContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'content',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisibleMessage, VisibleMessage, QAfterFilterCondition>
      contentMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'content',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisibleMessage, VisibleMessage, QAfterFilterCondition>
      contentIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'content',
        value: '',
      ));
    });
  }

  QueryBuilder<VisibleMessage, VisibleMessage, QAfterFilterCondition>
      contentIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'content',
        value: '',
      ));
    });
  }

  QueryBuilder<VisibleMessage, VisibleMessage, QAfterFilterCondition>
      deliveredAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'deliveredAt',
        value: value,
      ));
    });
  }

  QueryBuilder<VisibleMessage, VisibleMessage, QAfterFilterCondition>
      deliveredAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'deliveredAt',
        value: value,
      ));
    });
  }

  QueryBuilder<VisibleMessage, VisibleMessage, QAfterFilterCondition>
      deliveredAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'deliveredAt',
        value: value,
      ));
    });
  }

  QueryBuilder<VisibleMessage, VisibleMessage, QAfterFilterCondition>
      deliveredAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'deliveredAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<VisibleMessage, VisibleMessage, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<VisibleMessage, VisibleMessage, QAfterFilterCondition>
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

  QueryBuilder<VisibleMessage, VisibleMessage, QAfterFilterCondition>
      idLessThan(
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

  QueryBuilder<VisibleMessage, VisibleMessage, QAfterFilterCondition> idBetween(
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

  QueryBuilder<VisibleMessage, VisibleMessage, QAfterFilterCondition>
      originEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'origin',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisibleMessage, VisibleMessage, QAfterFilterCondition>
      originGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'origin',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisibleMessage, VisibleMessage, QAfterFilterCondition>
      originLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'origin',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisibleMessage, VisibleMessage, QAfterFilterCondition>
      originBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'origin',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisibleMessage, VisibleMessage, QAfterFilterCondition>
      originStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'origin',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisibleMessage, VisibleMessage, QAfterFilterCondition>
      originEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'origin',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisibleMessage, VisibleMessage, QAfterFilterCondition>
      originContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'origin',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisibleMessage, VisibleMessage, QAfterFilterCondition>
      originMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'origin',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisibleMessage, VisibleMessage, QAfterFilterCondition>
      originIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'origin',
        value: '',
      ));
    });
  }

  QueryBuilder<VisibleMessage, VisibleMessage, QAfterFilterCondition>
      originIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'origin',
        value: '',
      ));
    });
  }

  QueryBuilder<VisibleMessage, VisibleMessage, QAfterFilterCondition>
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

  QueryBuilder<VisibleMessage, VisibleMessage, QAfterFilterCondition>
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

  QueryBuilder<VisibleMessage, VisibleMessage, QAfterFilterCondition>
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

  QueryBuilder<VisibleMessage, VisibleMessage, QAfterFilterCondition>
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

  QueryBuilder<VisibleMessage, VisibleMessage, QAfterFilterCondition>
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

  QueryBuilder<VisibleMessage, VisibleMessage, QAfterFilterCondition>
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

  QueryBuilder<VisibleMessage, VisibleMessage, QAfterFilterCondition>
      saveSlotIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'saveSlotId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisibleMessage, VisibleMessage, QAfterFilterCondition>
      saveSlotIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'saveSlotId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisibleMessage, VisibleMessage, QAfterFilterCondition>
      saveSlotIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'saveSlotId',
        value: '',
      ));
    });
  }

  QueryBuilder<VisibleMessage, VisibleMessage, QAfterFilterCondition>
      saveSlotIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'saveSlotId',
        value: '',
      ));
    });
  }

  QueryBuilder<VisibleMessage, VisibleMessage, QAfterFilterCondition>
      sceneIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'sceneId',
      ));
    });
  }

  QueryBuilder<VisibleMessage, VisibleMessage, QAfterFilterCondition>
      sceneIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'sceneId',
      ));
    });
  }

  QueryBuilder<VisibleMessage, VisibleMessage, QAfterFilterCondition>
      sceneIdEqualTo(
    String? value, {
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

  QueryBuilder<VisibleMessage, VisibleMessage, QAfterFilterCondition>
      sceneIdGreaterThan(
    String? value, {
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

  QueryBuilder<VisibleMessage, VisibleMessage, QAfterFilterCondition>
      sceneIdLessThan(
    String? value, {
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

  QueryBuilder<VisibleMessage, VisibleMessage, QAfterFilterCondition>
      sceneIdBetween(
    String? lower,
    String? upper, {
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

  QueryBuilder<VisibleMessage, VisibleMessage, QAfterFilterCondition>
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

  QueryBuilder<VisibleMessage, VisibleMessage, QAfterFilterCondition>
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

  QueryBuilder<VisibleMessage, VisibleMessage, QAfterFilterCondition>
      sceneIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'sceneId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisibleMessage, VisibleMessage, QAfterFilterCondition>
      sceneIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'sceneId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisibleMessage, VisibleMessage, QAfterFilterCondition>
      sceneIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sceneId',
        value: '',
      ));
    });
  }

  QueryBuilder<VisibleMessage, VisibleMessage, QAfterFilterCondition>
      sceneIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'sceneId',
        value: '',
      ));
    });
  }

  QueryBuilder<VisibleMessage, VisibleMessage, QAfterFilterCondition>
      scriptIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'scriptId',
      ));
    });
  }

  QueryBuilder<VisibleMessage, VisibleMessage, QAfterFilterCondition>
      scriptIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'scriptId',
      ));
    });
  }

  QueryBuilder<VisibleMessage, VisibleMessage, QAfterFilterCondition>
      scriptIdEqualTo(
    String? value, {
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

  QueryBuilder<VisibleMessage, VisibleMessage, QAfterFilterCondition>
      scriptIdGreaterThan(
    String? value, {
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

  QueryBuilder<VisibleMessage, VisibleMessage, QAfterFilterCondition>
      scriptIdLessThan(
    String? value, {
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

  QueryBuilder<VisibleMessage, VisibleMessage, QAfterFilterCondition>
      scriptIdBetween(
    String? lower,
    String? upper, {
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

  QueryBuilder<VisibleMessage, VisibleMessage, QAfterFilterCondition>
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

  QueryBuilder<VisibleMessage, VisibleMessage, QAfterFilterCondition>
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

  QueryBuilder<VisibleMessage, VisibleMessage, QAfterFilterCondition>
      scriptIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'scriptId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisibleMessage, VisibleMessage, QAfterFilterCondition>
      scriptIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'scriptId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisibleMessage, VisibleMessage, QAfterFilterCondition>
      scriptIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'scriptId',
        value: '',
      ));
    });
  }

  QueryBuilder<VisibleMessage, VisibleMessage, QAfterFilterCondition>
      scriptIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'scriptId',
        value: '',
      ));
    });
  }

  QueryBuilder<VisibleMessage, VisibleMessage, QAfterFilterCondition>
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

  QueryBuilder<VisibleMessage, VisibleMessage, QAfterFilterCondition>
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

  QueryBuilder<VisibleMessage, VisibleMessage, QAfterFilterCondition>
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

  QueryBuilder<VisibleMessage, VisibleMessage, QAfterFilterCondition>
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

  QueryBuilder<VisibleMessage, VisibleMessage, QAfterFilterCondition>
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

  QueryBuilder<VisibleMessage, VisibleMessage, QAfterFilterCondition>
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

  QueryBuilder<VisibleMessage, VisibleMessage, QAfterFilterCondition>
      senderContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'sender',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisibleMessage, VisibleMessage, QAfterFilterCondition>
      senderMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'sender',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisibleMessage, VisibleMessage, QAfterFilterCondition>
      senderIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sender',
        value: '',
      ));
    });
  }

  QueryBuilder<VisibleMessage, VisibleMessage, QAfterFilterCondition>
      senderIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'sender',
        value: '',
      ));
    });
  }

  QueryBuilder<VisibleMessage, VisibleMessage, QAfterFilterCondition>
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

  QueryBuilder<VisibleMessage, VisibleMessage, QAfterFilterCondition>
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

  QueryBuilder<VisibleMessage, VisibleMessage, QAfterFilterCondition>
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

  QueryBuilder<VisibleMessage, VisibleMessage, QAfterFilterCondition>
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

  QueryBuilder<VisibleMessage, VisibleMessage, QAfterFilterCondition>
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

  QueryBuilder<VisibleMessage, VisibleMessage, QAfterFilterCondition>
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

  QueryBuilder<VisibleMessage, VisibleMessage, QAfterFilterCondition>
      threadIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'threadId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisibleMessage, VisibleMessage, QAfterFilterCondition>
      threadIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'threadId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisibleMessage, VisibleMessage, QAfterFilterCondition>
      threadIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'threadId',
        value: '',
      ));
    });
  }

  QueryBuilder<VisibleMessage, VisibleMessage, QAfterFilterCondition>
      threadIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'threadId',
        value: '',
      ));
    });
  }

  QueryBuilder<VisibleMessage, VisibleMessage, QAfterFilterCondition>
      typeEqualTo(
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

  QueryBuilder<VisibleMessage, VisibleMessage, QAfterFilterCondition>
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

  QueryBuilder<VisibleMessage, VisibleMessage, QAfterFilterCondition>
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

  QueryBuilder<VisibleMessage, VisibleMessage, QAfterFilterCondition>
      typeBetween(
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

  QueryBuilder<VisibleMessage, VisibleMessage, QAfterFilterCondition>
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

  QueryBuilder<VisibleMessage, VisibleMessage, QAfterFilterCondition>
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

  QueryBuilder<VisibleMessage, VisibleMessage, QAfterFilterCondition>
      typeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'type',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisibleMessage, VisibleMessage, QAfterFilterCondition>
      typeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'type',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VisibleMessage, VisibleMessage, QAfterFilterCondition>
      typeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'type',
        value: '',
      ));
    });
  }

  QueryBuilder<VisibleMessage, VisibleMessage, QAfterFilterCondition>
      typeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'type',
        value: '',
      ));
    });
  }
}

extension VisibleMessageQueryObject
    on QueryBuilder<VisibleMessage, VisibleMessage, QFilterCondition> {}

extension VisibleMessageQueryLinks
    on QueryBuilder<VisibleMessage, VisibleMessage, QFilterCondition> {}

extension VisibleMessageQuerySortBy
    on QueryBuilder<VisibleMessage, VisibleMessage, QSortBy> {
  QueryBuilder<VisibleMessage, VisibleMessage, QAfterSortBy>
      sortByChoicesJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'choicesJson', Sort.asc);
    });
  }

  QueryBuilder<VisibleMessage, VisibleMessage, QAfterSortBy>
      sortByChoicesJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'choicesJson', Sort.desc);
    });
  }

  QueryBuilder<VisibleMessage, VisibleMessage, QAfterSortBy> sortByContent() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'content', Sort.asc);
    });
  }

  QueryBuilder<VisibleMessage, VisibleMessage, QAfterSortBy>
      sortByContentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'content', Sort.desc);
    });
  }

  QueryBuilder<VisibleMessage, VisibleMessage, QAfterSortBy>
      sortByDeliveredAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deliveredAt', Sort.asc);
    });
  }

  QueryBuilder<VisibleMessage, VisibleMessage, QAfterSortBy>
      sortByDeliveredAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deliveredAt', Sort.desc);
    });
  }

  QueryBuilder<VisibleMessage, VisibleMessage, QAfterSortBy> sortByOrigin() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'origin', Sort.asc);
    });
  }

  QueryBuilder<VisibleMessage, VisibleMessage, QAfterSortBy>
      sortByOriginDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'origin', Sort.desc);
    });
  }

  QueryBuilder<VisibleMessage, VisibleMessage, QAfterSortBy>
      sortBySaveSlotId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'saveSlotId', Sort.asc);
    });
  }

  QueryBuilder<VisibleMessage, VisibleMessage, QAfterSortBy>
      sortBySaveSlotIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'saveSlotId', Sort.desc);
    });
  }

  QueryBuilder<VisibleMessage, VisibleMessage, QAfterSortBy> sortBySceneId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sceneId', Sort.asc);
    });
  }

  QueryBuilder<VisibleMessage, VisibleMessage, QAfterSortBy>
      sortBySceneIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sceneId', Sort.desc);
    });
  }

  QueryBuilder<VisibleMessage, VisibleMessage, QAfterSortBy> sortByScriptId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scriptId', Sort.asc);
    });
  }

  QueryBuilder<VisibleMessage, VisibleMessage, QAfterSortBy>
      sortByScriptIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scriptId', Sort.desc);
    });
  }

  QueryBuilder<VisibleMessage, VisibleMessage, QAfterSortBy> sortBySender() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sender', Sort.asc);
    });
  }

  QueryBuilder<VisibleMessage, VisibleMessage, QAfterSortBy>
      sortBySenderDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sender', Sort.desc);
    });
  }

  QueryBuilder<VisibleMessage, VisibleMessage, QAfterSortBy> sortByThreadId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'threadId', Sort.asc);
    });
  }

  QueryBuilder<VisibleMessage, VisibleMessage, QAfterSortBy>
      sortByThreadIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'threadId', Sort.desc);
    });
  }

  QueryBuilder<VisibleMessage, VisibleMessage, QAfterSortBy> sortByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.asc);
    });
  }

  QueryBuilder<VisibleMessage, VisibleMessage, QAfterSortBy> sortByTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.desc);
    });
  }
}

extension VisibleMessageQuerySortThenBy
    on QueryBuilder<VisibleMessage, VisibleMessage, QSortThenBy> {
  QueryBuilder<VisibleMessage, VisibleMessage, QAfterSortBy>
      thenByChoicesJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'choicesJson', Sort.asc);
    });
  }

  QueryBuilder<VisibleMessage, VisibleMessage, QAfterSortBy>
      thenByChoicesJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'choicesJson', Sort.desc);
    });
  }

  QueryBuilder<VisibleMessage, VisibleMessage, QAfterSortBy> thenByContent() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'content', Sort.asc);
    });
  }

  QueryBuilder<VisibleMessage, VisibleMessage, QAfterSortBy>
      thenByContentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'content', Sort.desc);
    });
  }

  QueryBuilder<VisibleMessage, VisibleMessage, QAfterSortBy>
      thenByDeliveredAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deliveredAt', Sort.asc);
    });
  }

  QueryBuilder<VisibleMessage, VisibleMessage, QAfterSortBy>
      thenByDeliveredAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deliveredAt', Sort.desc);
    });
  }

  QueryBuilder<VisibleMessage, VisibleMessage, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<VisibleMessage, VisibleMessage, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<VisibleMessage, VisibleMessage, QAfterSortBy> thenByOrigin() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'origin', Sort.asc);
    });
  }

  QueryBuilder<VisibleMessage, VisibleMessage, QAfterSortBy>
      thenByOriginDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'origin', Sort.desc);
    });
  }

  QueryBuilder<VisibleMessage, VisibleMessage, QAfterSortBy>
      thenBySaveSlotId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'saveSlotId', Sort.asc);
    });
  }

  QueryBuilder<VisibleMessage, VisibleMessage, QAfterSortBy>
      thenBySaveSlotIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'saveSlotId', Sort.desc);
    });
  }

  QueryBuilder<VisibleMessage, VisibleMessage, QAfterSortBy> thenBySceneId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sceneId', Sort.asc);
    });
  }

  QueryBuilder<VisibleMessage, VisibleMessage, QAfterSortBy>
      thenBySceneIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sceneId', Sort.desc);
    });
  }

  QueryBuilder<VisibleMessage, VisibleMessage, QAfterSortBy> thenByScriptId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scriptId', Sort.asc);
    });
  }

  QueryBuilder<VisibleMessage, VisibleMessage, QAfterSortBy>
      thenByScriptIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scriptId', Sort.desc);
    });
  }

  QueryBuilder<VisibleMessage, VisibleMessage, QAfterSortBy> thenBySender() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sender', Sort.asc);
    });
  }

  QueryBuilder<VisibleMessage, VisibleMessage, QAfterSortBy>
      thenBySenderDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sender', Sort.desc);
    });
  }

  QueryBuilder<VisibleMessage, VisibleMessage, QAfterSortBy> thenByThreadId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'threadId', Sort.asc);
    });
  }

  QueryBuilder<VisibleMessage, VisibleMessage, QAfterSortBy>
      thenByThreadIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'threadId', Sort.desc);
    });
  }

  QueryBuilder<VisibleMessage, VisibleMessage, QAfterSortBy> thenByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.asc);
    });
  }

  QueryBuilder<VisibleMessage, VisibleMessage, QAfterSortBy> thenByTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.desc);
    });
  }
}

extension VisibleMessageQueryWhereDistinct
    on QueryBuilder<VisibleMessage, VisibleMessage, QDistinct> {
  QueryBuilder<VisibleMessage, VisibleMessage, QDistinct> distinctByChoicesJson(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'choicesJson', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<VisibleMessage, VisibleMessage, QDistinct> distinctByContent(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'content', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<VisibleMessage, VisibleMessage, QDistinct>
      distinctByDeliveredAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'deliveredAt');
    });
  }

  QueryBuilder<VisibleMessage, VisibleMessage, QDistinct> distinctByOrigin(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'origin', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<VisibleMessage, VisibleMessage, QDistinct> distinctBySaveSlotId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'saveSlotId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<VisibleMessage, VisibleMessage, QDistinct> distinctBySceneId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sceneId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<VisibleMessage, VisibleMessage, QDistinct> distinctByScriptId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'scriptId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<VisibleMessage, VisibleMessage, QDistinct> distinctBySender(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sender', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<VisibleMessage, VisibleMessage, QDistinct> distinctByThreadId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'threadId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<VisibleMessage, VisibleMessage, QDistinct> distinctByType(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'type', caseSensitive: caseSensitive);
    });
  }
}

extension VisibleMessageQueryProperty
    on QueryBuilder<VisibleMessage, VisibleMessage, QQueryProperty> {
  QueryBuilder<VisibleMessage, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<VisibleMessage, String?, QQueryOperations>
      choicesJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'choicesJson');
    });
  }

  QueryBuilder<VisibleMessage, String, QQueryOperations> contentProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'content');
    });
  }

  QueryBuilder<VisibleMessage, DateTime, QQueryOperations>
      deliveredAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'deliveredAt');
    });
  }

  QueryBuilder<VisibleMessage, String, QQueryOperations> originProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'origin');
    });
  }

  QueryBuilder<VisibleMessage, String, QQueryOperations> saveSlotIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'saveSlotId');
    });
  }

  QueryBuilder<VisibleMessage, String?, QQueryOperations> sceneIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sceneId');
    });
  }

  QueryBuilder<VisibleMessage, String?, QQueryOperations> scriptIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'scriptId');
    });
  }

  QueryBuilder<VisibleMessage, String, QQueryOperations> senderProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sender');
    });
  }

  QueryBuilder<VisibleMessage, String, QQueryOperations> threadIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'threadId');
    });
  }

  QueryBuilder<VisibleMessage, String, QQueryOperations> typeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'type');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetPendingDeliveryCollection on Isar {
  IsarCollection<PendingDelivery> get pendingDeliverys => this.collection();
}

const PendingDeliverySchema = CollectionSchema(
  name: r'PendingDelivery',
  id: 2046124037008066244,
  properties: {
    r'content': PropertySchema(
      id: 0,
      name: r'content',
      type: IsarType.string,
    ),
    r'deliverAt': PropertySchema(
      id: 1,
      name: r'deliverAt',
      type: IsarType.dateTime,
    ),
    r'saveSlotId': PropertySchema(
      id: 2,
      name: r'saveSlotId',
      type: IsarType.string,
    ),
    r'scriptId': PropertySchema(
      id: 3,
      name: r'scriptId',
      type: IsarType.string,
    ),
    r'sender': PropertySchema(
      id: 4,
      name: r'sender',
      type: IsarType.string,
    ),
    r'status': PropertySchema(
      id: 5,
      name: r'status',
      type: IsarType.string,
    ),
    r'threadId': PropertySchema(
      id: 6,
      name: r'threadId',
      type: IsarType.string,
    ),
    r'type': PropertySchema(
      id: 7,
      name: r'type',
      type: IsarType.string,
    ),
    r'typingStartAt': PropertySchema(
      id: 8,
      name: r'typingStartAt',
      type: IsarType.dateTime,
    )
  },
  estimateSize: _pendingDeliveryEstimateSize,
  serialize: _pendingDeliverySerialize,
  deserialize: _pendingDeliveryDeserialize,
  deserializeProp: _pendingDeliveryDeserializeProp,
  idName: r'id',
  indexes: {
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
    ),
    r'status': IndexSchema(
      id: -107785170620420283,
      name: r'status',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'status',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _pendingDeliveryGetId,
  getLinks: _pendingDeliveryGetLinks,
  attach: _pendingDeliveryAttach,
  version: '3.1.0+1',
);

int _pendingDeliveryEstimateSize(
  PendingDelivery object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.content.length * 3;
  bytesCount += 3 + object.saveSlotId.length * 3;
  bytesCount += 3 + object.scriptId.length * 3;
  bytesCount += 3 + object.sender.length * 3;
  bytesCount += 3 + object.status.length * 3;
  bytesCount += 3 + object.threadId.length * 3;
  bytesCount += 3 + object.type.length * 3;
  return bytesCount;
}

void _pendingDeliverySerialize(
  PendingDelivery object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.content);
  writer.writeDateTime(offsets[1], object.deliverAt);
  writer.writeString(offsets[2], object.saveSlotId);
  writer.writeString(offsets[3], object.scriptId);
  writer.writeString(offsets[4], object.sender);
  writer.writeString(offsets[5], object.status);
  writer.writeString(offsets[6], object.threadId);
  writer.writeString(offsets[7], object.type);
  writer.writeDateTime(offsets[8], object.typingStartAt);
}

PendingDelivery _pendingDeliveryDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = PendingDelivery();
  object.content = reader.readString(offsets[0]);
  object.deliverAt = reader.readDateTime(offsets[1]);
  object.id = id;
  object.saveSlotId = reader.readString(offsets[2]);
  object.scriptId = reader.readString(offsets[3]);
  object.sender = reader.readString(offsets[4]);
  object.status = reader.readString(offsets[5]);
  object.threadId = reader.readString(offsets[6]);
  object.type = reader.readString(offsets[7]);
  object.typingStartAt = reader.readDateTime(offsets[8]);
  return object;
}

P _pendingDeliveryDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readDateTime(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readString(offset)) as P;
    case 8:
      return (reader.readDateTime(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _pendingDeliveryGetId(PendingDelivery object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _pendingDeliveryGetLinks(PendingDelivery object) {
  return [];
}

void _pendingDeliveryAttach(
    IsarCollection<dynamic> col, Id id, PendingDelivery object) {
  object.id = id;
}

extension PendingDeliveryQueryWhereSort
    on QueryBuilder<PendingDelivery, PendingDelivery, QWhere> {
  QueryBuilder<PendingDelivery, PendingDelivery, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension PendingDeliveryQueryWhere
    on QueryBuilder<PendingDelivery, PendingDelivery, QWhereClause> {
  QueryBuilder<PendingDelivery, PendingDelivery, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<PendingDelivery, PendingDelivery, QAfterWhereClause>
      idNotEqualTo(Id id) {
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

  QueryBuilder<PendingDelivery, PendingDelivery, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<PendingDelivery, PendingDelivery, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<PendingDelivery, PendingDelivery, QAfterWhereClause> idBetween(
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

  QueryBuilder<PendingDelivery, PendingDelivery, QAfterWhereClause>
      threadIdEqualTo(String threadId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'threadId',
        value: [threadId],
      ));
    });
  }

  QueryBuilder<PendingDelivery, PendingDelivery, QAfterWhereClause>
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

  QueryBuilder<PendingDelivery, PendingDelivery, QAfterWhereClause>
      statusEqualTo(String status) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'status',
        value: [status],
      ));
    });
  }

  QueryBuilder<PendingDelivery, PendingDelivery, QAfterWhereClause>
      statusNotEqualTo(String status) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'status',
              lower: [],
              upper: [status],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'status',
              lower: [status],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'status',
              lower: [status],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'status',
              lower: [],
              upper: [status],
              includeUpper: false,
            ));
      }
    });
  }
}

extension PendingDeliveryQueryFilter
    on QueryBuilder<PendingDelivery, PendingDelivery, QFilterCondition> {
  QueryBuilder<PendingDelivery, PendingDelivery, QAfterFilterCondition>
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

  QueryBuilder<PendingDelivery, PendingDelivery, QAfterFilterCondition>
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

  QueryBuilder<PendingDelivery, PendingDelivery, QAfterFilterCondition>
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

  QueryBuilder<PendingDelivery, PendingDelivery, QAfterFilterCondition>
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

  QueryBuilder<PendingDelivery, PendingDelivery, QAfterFilterCondition>
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

  QueryBuilder<PendingDelivery, PendingDelivery, QAfterFilterCondition>
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

  QueryBuilder<PendingDelivery, PendingDelivery, QAfterFilterCondition>
      contentContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'content',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingDelivery, PendingDelivery, QAfterFilterCondition>
      contentMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'content',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingDelivery, PendingDelivery, QAfterFilterCondition>
      contentIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'content',
        value: '',
      ));
    });
  }

  QueryBuilder<PendingDelivery, PendingDelivery, QAfterFilterCondition>
      contentIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'content',
        value: '',
      ));
    });
  }

  QueryBuilder<PendingDelivery, PendingDelivery, QAfterFilterCondition>
      deliverAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'deliverAt',
        value: value,
      ));
    });
  }

  QueryBuilder<PendingDelivery, PendingDelivery, QAfterFilterCondition>
      deliverAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'deliverAt',
        value: value,
      ));
    });
  }

  QueryBuilder<PendingDelivery, PendingDelivery, QAfterFilterCondition>
      deliverAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'deliverAt',
        value: value,
      ));
    });
  }

  QueryBuilder<PendingDelivery, PendingDelivery, QAfterFilterCondition>
      deliverAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'deliverAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PendingDelivery, PendingDelivery, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<PendingDelivery, PendingDelivery, QAfterFilterCondition>
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

  QueryBuilder<PendingDelivery, PendingDelivery, QAfterFilterCondition>
      idLessThan(
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

  QueryBuilder<PendingDelivery, PendingDelivery, QAfterFilterCondition>
      idBetween(
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

  QueryBuilder<PendingDelivery, PendingDelivery, QAfterFilterCondition>
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

  QueryBuilder<PendingDelivery, PendingDelivery, QAfterFilterCondition>
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

  QueryBuilder<PendingDelivery, PendingDelivery, QAfterFilterCondition>
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

  QueryBuilder<PendingDelivery, PendingDelivery, QAfterFilterCondition>
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

  QueryBuilder<PendingDelivery, PendingDelivery, QAfterFilterCondition>
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

  QueryBuilder<PendingDelivery, PendingDelivery, QAfterFilterCondition>
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

  QueryBuilder<PendingDelivery, PendingDelivery, QAfterFilterCondition>
      saveSlotIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'saveSlotId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingDelivery, PendingDelivery, QAfterFilterCondition>
      saveSlotIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'saveSlotId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingDelivery, PendingDelivery, QAfterFilterCondition>
      saveSlotIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'saveSlotId',
        value: '',
      ));
    });
  }

  QueryBuilder<PendingDelivery, PendingDelivery, QAfterFilterCondition>
      saveSlotIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'saveSlotId',
        value: '',
      ));
    });
  }

  QueryBuilder<PendingDelivery, PendingDelivery, QAfterFilterCondition>
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

  QueryBuilder<PendingDelivery, PendingDelivery, QAfterFilterCondition>
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

  QueryBuilder<PendingDelivery, PendingDelivery, QAfterFilterCondition>
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

  QueryBuilder<PendingDelivery, PendingDelivery, QAfterFilterCondition>
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

  QueryBuilder<PendingDelivery, PendingDelivery, QAfterFilterCondition>
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

  QueryBuilder<PendingDelivery, PendingDelivery, QAfterFilterCondition>
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

  QueryBuilder<PendingDelivery, PendingDelivery, QAfterFilterCondition>
      scriptIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'scriptId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingDelivery, PendingDelivery, QAfterFilterCondition>
      scriptIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'scriptId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingDelivery, PendingDelivery, QAfterFilterCondition>
      scriptIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'scriptId',
        value: '',
      ));
    });
  }

  QueryBuilder<PendingDelivery, PendingDelivery, QAfterFilterCondition>
      scriptIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'scriptId',
        value: '',
      ));
    });
  }

  QueryBuilder<PendingDelivery, PendingDelivery, QAfterFilterCondition>
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

  QueryBuilder<PendingDelivery, PendingDelivery, QAfterFilterCondition>
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

  QueryBuilder<PendingDelivery, PendingDelivery, QAfterFilterCondition>
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

  QueryBuilder<PendingDelivery, PendingDelivery, QAfterFilterCondition>
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

  QueryBuilder<PendingDelivery, PendingDelivery, QAfterFilterCondition>
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

  QueryBuilder<PendingDelivery, PendingDelivery, QAfterFilterCondition>
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

  QueryBuilder<PendingDelivery, PendingDelivery, QAfterFilterCondition>
      senderContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'sender',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingDelivery, PendingDelivery, QAfterFilterCondition>
      senderMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'sender',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingDelivery, PendingDelivery, QAfterFilterCondition>
      senderIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sender',
        value: '',
      ));
    });
  }

  QueryBuilder<PendingDelivery, PendingDelivery, QAfterFilterCondition>
      senderIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'sender',
        value: '',
      ));
    });
  }

  QueryBuilder<PendingDelivery, PendingDelivery, QAfterFilterCondition>
      statusEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingDelivery, PendingDelivery, QAfterFilterCondition>
      statusGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingDelivery, PendingDelivery, QAfterFilterCondition>
      statusLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingDelivery, PendingDelivery, QAfterFilterCondition>
      statusBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'status',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingDelivery, PendingDelivery, QAfterFilterCondition>
      statusStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingDelivery, PendingDelivery, QAfterFilterCondition>
      statusEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingDelivery, PendingDelivery, QAfterFilterCondition>
      statusContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingDelivery, PendingDelivery, QAfterFilterCondition>
      statusMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'status',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingDelivery, PendingDelivery, QAfterFilterCondition>
      statusIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'status',
        value: '',
      ));
    });
  }

  QueryBuilder<PendingDelivery, PendingDelivery, QAfterFilterCondition>
      statusIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'status',
        value: '',
      ));
    });
  }

  QueryBuilder<PendingDelivery, PendingDelivery, QAfterFilterCondition>
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

  QueryBuilder<PendingDelivery, PendingDelivery, QAfterFilterCondition>
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

  QueryBuilder<PendingDelivery, PendingDelivery, QAfterFilterCondition>
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

  QueryBuilder<PendingDelivery, PendingDelivery, QAfterFilterCondition>
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

  QueryBuilder<PendingDelivery, PendingDelivery, QAfterFilterCondition>
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

  QueryBuilder<PendingDelivery, PendingDelivery, QAfterFilterCondition>
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

  QueryBuilder<PendingDelivery, PendingDelivery, QAfterFilterCondition>
      threadIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'threadId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingDelivery, PendingDelivery, QAfterFilterCondition>
      threadIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'threadId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingDelivery, PendingDelivery, QAfterFilterCondition>
      threadIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'threadId',
        value: '',
      ));
    });
  }

  QueryBuilder<PendingDelivery, PendingDelivery, QAfterFilterCondition>
      threadIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'threadId',
        value: '',
      ));
    });
  }

  QueryBuilder<PendingDelivery, PendingDelivery, QAfterFilterCondition>
      typeEqualTo(
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

  QueryBuilder<PendingDelivery, PendingDelivery, QAfterFilterCondition>
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

  QueryBuilder<PendingDelivery, PendingDelivery, QAfterFilterCondition>
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

  QueryBuilder<PendingDelivery, PendingDelivery, QAfterFilterCondition>
      typeBetween(
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

  QueryBuilder<PendingDelivery, PendingDelivery, QAfterFilterCondition>
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

  QueryBuilder<PendingDelivery, PendingDelivery, QAfterFilterCondition>
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

  QueryBuilder<PendingDelivery, PendingDelivery, QAfterFilterCondition>
      typeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'type',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingDelivery, PendingDelivery, QAfterFilterCondition>
      typeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'type',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PendingDelivery, PendingDelivery, QAfterFilterCondition>
      typeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'type',
        value: '',
      ));
    });
  }

  QueryBuilder<PendingDelivery, PendingDelivery, QAfterFilterCondition>
      typeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'type',
        value: '',
      ));
    });
  }

  QueryBuilder<PendingDelivery, PendingDelivery, QAfterFilterCondition>
      typingStartAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'typingStartAt',
        value: value,
      ));
    });
  }

  QueryBuilder<PendingDelivery, PendingDelivery, QAfterFilterCondition>
      typingStartAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'typingStartAt',
        value: value,
      ));
    });
  }

  QueryBuilder<PendingDelivery, PendingDelivery, QAfterFilterCondition>
      typingStartAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'typingStartAt',
        value: value,
      ));
    });
  }

  QueryBuilder<PendingDelivery, PendingDelivery, QAfterFilterCondition>
      typingStartAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'typingStartAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension PendingDeliveryQueryObject
    on QueryBuilder<PendingDelivery, PendingDelivery, QFilterCondition> {}

extension PendingDeliveryQueryLinks
    on QueryBuilder<PendingDelivery, PendingDelivery, QFilterCondition> {}

extension PendingDeliveryQuerySortBy
    on QueryBuilder<PendingDelivery, PendingDelivery, QSortBy> {
  QueryBuilder<PendingDelivery, PendingDelivery, QAfterSortBy> sortByContent() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'content', Sort.asc);
    });
  }

  QueryBuilder<PendingDelivery, PendingDelivery, QAfterSortBy>
      sortByContentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'content', Sort.desc);
    });
  }

  QueryBuilder<PendingDelivery, PendingDelivery, QAfterSortBy>
      sortByDeliverAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deliverAt', Sort.asc);
    });
  }

  QueryBuilder<PendingDelivery, PendingDelivery, QAfterSortBy>
      sortByDeliverAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deliverAt', Sort.desc);
    });
  }

  QueryBuilder<PendingDelivery, PendingDelivery, QAfterSortBy>
      sortBySaveSlotId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'saveSlotId', Sort.asc);
    });
  }

  QueryBuilder<PendingDelivery, PendingDelivery, QAfterSortBy>
      sortBySaveSlotIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'saveSlotId', Sort.desc);
    });
  }

  QueryBuilder<PendingDelivery, PendingDelivery, QAfterSortBy>
      sortByScriptId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scriptId', Sort.asc);
    });
  }

  QueryBuilder<PendingDelivery, PendingDelivery, QAfterSortBy>
      sortByScriptIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scriptId', Sort.desc);
    });
  }

  QueryBuilder<PendingDelivery, PendingDelivery, QAfterSortBy> sortBySender() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sender', Sort.asc);
    });
  }

  QueryBuilder<PendingDelivery, PendingDelivery, QAfterSortBy>
      sortBySenderDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sender', Sort.desc);
    });
  }

  QueryBuilder<PendingDelivery, PendingDelivery, QAfterSortBy> sortByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<PendingDelivery, PendingDelivery, QAfterSortBy>
      sortByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<PendingDelivery, PendingDelivery, QAfterSortBy>
      sortByThreadId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'threadId', Sort.asc);
    });
  }

  QueryBuilder<PendingDelivery, PendingDelivery, QAfterSortBy>
      sortByThreadIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'threadId', Sort.desc);
    });
  }

  QueryBuilder<PendingDelivery, PendingDelivery, QAfterSortBy> sortByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.asc);
    });
  }

  QueryBuilder<PendingDelivery, PendingDelivery, QAfterSortBy>
      sortByTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.desc);
    });
  }

  QueryBuilder<PendingDelivery, PendingDelivery, QAfterSortBy>
      sortByTypingStartAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'typingStartAt', Sort.asc);
    });
  }

  QueryBuilder<PendingDelivery, PendingDelivery, QAfterSortBy>
      sortByTypingStartAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'typingStartAt', Sort.desc);
    });
  }
}

extension PendingDeliveryQuerySortThenBy
    on QueryBuilder<PendingDelivery, PendingDelivery, QSortThenBy> {
  QueryBuilder<PendingDelivery, PendingDelivery, QAfterSortBy> thenByContent() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'content', Sort.asc);
    });
  }

  QueryBuilder<PendingDelivery, PendingDelivery, QAfterSortBy>
      thenByContentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'content', Sort.desc);
    });
  }

  QueryBuilder<PendingDelivery, PendingDelivery, QAfterSortBy>
      thenByDeliverAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deliverAt', Sort.asc);
    });
  }

  QueryBuilder<PendingDelivery, PendingDelivery, QAfterSortBy>
      thenByDeliverAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deliverAt', Sort.desc);
    });
  }

  QueryBuilder<PendingDelivery, PendingDelivery, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<PendingDelivery, PendingDelivery, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<PendingDelivery, PendingDelivery, QAfterSortBy>
      thenBySaveSlotId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'saveSlotId', Sort.asc);
    });
  }

  QueryBuilder<PendingDelivery, PendingDelivery, QAfterSortBy>
      thenBySaveSlotIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'saveSlotId', Sort.desc);
    });
  }

  QueryBuilder<PendingDelivery, PendingDelivery, QAfterSortBy>
      thenByScriptId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scriptId', Sort.asc);
    });
  }

  QueryBuilder<PendingDelivery, PendingDelivery, QAfterSortBy>
      thenByScriptIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'scriptId', Sort.desc);
    });
  }

  QueryBuilder<PendingDelivery, PendingDelivery, QAfterSortBy> thenBySender() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sender', Sort.asc);
    });
  }

  QueryBuilder<PendingDelivery, PendingDelivery, QAfterSortBy>
      thenBySenderDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sender', Sort.desc);
    });
  }

  QueryBuilder<PendingDelivery, PendingDelivery, QAfterSortBy> thenByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<PendingDelivery, PendingDelivery, QAfterSortBy>
      thenByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<PendingDelivery, PendingDelivery, QAfterSortBy>
      thenByThreadId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'threadId', Sort.asc);
    });
  }

  QueryBuilder<PendingDelivery, PendingDelivery, QAfterSortBy>
      thenByThreadIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'threadId', Sort.desc);
    });
  }

  QueryBuilder<PendingDelivery, PendingDelivery, QAfterSortBy> thenByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.asc);
    });
  }

  QueryBuilder<PendingDelivery, PendingDelivery, QAfterSortBy>
      thenByTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.desc);
    });
  }

  QueryBuilder<PendingDelivery, PendingDelivery, QAfterSortBy>
      thenByTypingStartAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'typingStartAt', Sort.asc);
    });
  }

  QueryBuilder<PendingDelivery, PendingDelivery, QAfterSortBy>
      thenByTypingStartAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'typingStartAt', Sort.desc);
    });
  }
}

extension PendingDeliveryQueryWhereDistinct
    on QueryBuilder<PendingDelivery, PendingDelivery, QDistinct> {
  QueryBuilder<PendingDelivery, PendingDelivery, QDistinct> distinctByContent(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'content', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PendingDelivery, PendingDelivery, QDistinct>
      distinctByDeliverAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'deliverAt');
    });
  }

  QueryBuilder<PendingDelivery, PendingDelivery, QDistinct>
      distinctBySaveSlotId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'saveSlotId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PendingDelivery, PendingDelivery, QDistinct> distinctByScriptId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'scriptId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PendingDelivery, PendingDelivery, QDistinct> distinctBySender(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sender', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PendingDelivery, PendingDelivery, QDistinct> distinctByStatus(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'status', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PendingDelivery, PendingDelivery, QDistinct> distinctByThreadId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'threadId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PendingDelivery, PendingDelivery, QDistinct> distinctByType(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'type', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PendingDelivery, PendingDelivery, QDistinct>
      distinctByTypingStartAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'typingStartAt');
    });
  }
}

extension PendingDeliveryQueryProperty
    on QueryBuilder<PendingDelivery, PendingDelivery, QQueryProperty> {
  QueryBuilder<PendingDelivery, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<PendingDelivery, String, QQueryOperations> contentProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'content');
    });
  }

  QueryBuilder<PendingDelivery, DateTime, QQueryOperations>
      deliverAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'deliverAt');
    });
  }

  QueryBuilder<PendingDelivery, String, QQueryOperations> saveSlotIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'saveSlotId');
    });
  }

  QueryBuilder<PendingDelivery, String, QQueryOperations> scriptIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'scriptId');
    });
  }

  QueryBuilder<PendingDelivery, String, QQueryOperations> senderProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sender');
    });
  }

  QueryBuilder<PendingDelivery, String, QQueryOperations> statusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'status');
    });
  }

  QueryBuilder<PendingDelivery, String, QQueryOperations> threadIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'threadId');
    });
  }

  QueryBuilder<PendingDelivery, String, QQueryOperations> typeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'type');
    });
  }

  QueryBuilder<PendingDelivery, DateTime, QQueryOperations>
      typingStartAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'typingStartAt');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetThreadPlaybackStateCollection on Isar {
  IsarCollection<ThreadPlaybackState> get threadPlaybackStates =>
      this.collection();
}

const ThreadPlaybackStateSchema = CollectionSchema(
  name: r'ThreadPlaybackState',
  id: -4836972954523100622,
  properties: {
    r'compositeId': PropertySchema(
      id: 0,
      name: r'compositeId',
      type: IsarType.string,
    ),
    r'currentSceneId': PropertySchema(
      id: 1,
      name: r'currentSceneId',
      type: IsarType.string,
    ),
    r'cursor': PropertySchema(
      id: 2,
      name: r'cursor',
      type: IsarType.long,
    ),
    r'lastReadAt': PropertySchema(
      id: 3,
      name: r'lastReadAt',
      type: IsarType.dateTime,
    ),
    r'saveSlotId': PropertySchema(
      id: 4,
      name: r'saveSlotId',
      type: IsarType.string,
    ),
    r'threadId': PropertySchema(
      id: 5,
      name: r'threadId',
      type: IsarType.string,
    )
  },
  estimateSize: _threadPlaybackStateEstimateSize,
  serialize: _threadPlaybackStateSerialize,
  deserialize: _threadPlaybackStateDeserialize,
  deserializeProp: _threadPlaybackStateDeserializeProp,
  idName: r'id',
  indexes: {
    r'compositeId': IndexSchema(
      id: 8837095547420355760,
      name: r'compositeId',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'compositeId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _threadPlaybackStateGetId,
  getLinks: _threadPlaybackStateGetLinks,
  attach: _threadPlaybackStateAttach,
  version: '3.1.0+1',
);

int _threadPlaybackStateEstimateSize(
  ThreadPlaybackState object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.compositeId.length * 3;
  bytesCount += 3 + object.currentSceneId.length * 3;
  bytesCount += 3 + object.saveSlotId.length * 3;
  bytesCount += 3 + object.threadId.length * 3;
  return bytesCount;
}

void _threadPlaybackStateSerialize(
  ThreadPlaybackState object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.compositeId);
  writer.writeString(offsets[1], object.currentSceneId);
  writer.writeLong(offsets[2], object.cursor);
  writer.writeDateTime(offsets[3], object.lastReadAt);
  writer.writeString(offsets[4], object.saveSlotId);
  writer.writeString(offsets[5], object.threadId);
}

ThreadPlaybackState _threadPlaybackStateDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = ThreadPlaybackState();
  object.compositeId = reader.readString(offsets[0]);
  object.currentSceneId = reader.readString(offsets[1]);
  object.cursor = reader.readLong(offsets[2]);
  object.id = id;
  object.lastReadAt = reader.readDateTimeOrNull(offsets[3]);
  object.saveSlotId = reader.readString(offsets[4]);
  object.threadId = reader.readString(offsets[5]);
  return object;
}

P _threadPlaybackStateDeserializeProp<P>(
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
      return (reader.readLong(offset)) as P;
    case 3:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _threadPlaybackStateGetId(ThreadPlaybackState object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _threadPlaybackStateGetLinks(
    ThreadPlaybackState object) {
  return [];
}

void _threadPlaybackStateAttach(
    IsarCollection<dynamic> col, Id id, ThreadPlaybackState object) {
  object.id = id;
}

extension ThreadPlaybackStateByIndex on IsarCollection<ThreadPlaybackState> {
  Future<ThreadPlaybackState?> getByCompositeId(String compositeId) {
    return getByIndex(r'compositeId', [compositeId]);
  }

  ThreadPlaybackState? getByCompositeIdSync(String compositeId) {
    return getByIndexSync(r'compositeId', [compositeId]);
  }

  Future<bool> deleteByCompositeId(String compositeId) {
    return deleteByIndex(r'compositeId', [compositeId]);
  }

  bool deleteByCompositeIdSync(String compositeId) {
    return deleteByIndexSync(r'compositeId', [compositeId]);
  }

  Future<List<ThreadPlaybackState?>> getAllByCompositeId(
      List<String> compositeIdValues) {
    final values = compositeIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'compositeId', values);
  }

  List<ThreadPlaybackState?> getAllByCompositeIdSync(
      List<String> compositeIdValues) {
    final values = compositeIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'compositeId', values);
  }

  Future<int> deleteAllByCompositeId(List<String> compositeIdValues) {
    final values = compositeIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'compositeId', values);
  }

  int deleteAllByCompositeIdSync(List<String> compositeIdValues) {
    final values = compositeIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'compositeId', values);
  }

  Future<Id> putByCompositeId(ThreadPlaybackState object) {
    return putByIndex(r'compositeId', object);
  }

  Id putByCompositeIdSync(ThreadPlaybackState object, {bool saveLinks = true}) {
    return putByIndexSync(r'compositeId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByCompositeId(List<ThreadPlaybackState> objects) {
    return putAllByIndex(r'compositeId', objects);
  }

  List<Id> putAllByCompositeIdSync(List<ThreadPlaybackState> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'compositeId', objects, saveLinks: saveLinks);
  }
}

extension ThreadPlaybackStateQueryWhereSort
    on QueryBuilder<ThreadPlaybackState, ThreadPlaybackState, QWhere> {
  QueryBuilder<ThreadPlaybackState, ThreadPlaybackState, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension ThreadPlaybackStateQueryWhere
    on QueryBuilder<ThreadPlaybackState, ThreadPlaybackState, QWhereClause> {
  QueryBuilder<ThreadPlaybackState, ThreadPlaybackState, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<ThreadPlaybackState, ThreadPlaybackState, QAfterWhereClause>
      idNotEqualTo(Id id) {
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

  QueryBuilder<ThreadPlaybackState, ThreadPlaybackState, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<ThreadPlaybackState, ThreadPlaybackState, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<ThreadPlaybackState, ThreadPlaybackState, QAfterWhereClause>
      idBetween(
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

  QueryBuilder<ThreadPlaybackState, ThreadPlaybackState, QAfterWhereClause>
      compositeIdEqualTo(String compositeId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'compositeId',
        value: [compositeId],
      ));
    });
  }

  QueryBuilder<ThreadPlaybackState, ThreadPlaybackState, QAfterWhereClause>
      compositeIdNotEqualTo(String compositeId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'compositeId',
              lower: [],
              upper: [compositeId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'compositeId',
              lower: [compositeId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'compositeId',
              lower: [compositeId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'compositeId',
              lower: [],
              upper: [compositeId],
              includeUpper: false,
            ));
      }
    });
  }
}

extension ThreadPlaybackStateQueryFilter on QueryBuilder<ThreadPlaybackState,
    ThreadPlaybackState, QFilterCondition> {
  QueryBuilder<ThreadPlaybackState, ThreadPlaybackState, QAfterFilterCondition>
      compositeIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'compositeId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ThreadPlaybackState, ThreadPlaybackState, QAfterFilterCondition>
      compositeIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'compositeId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ThreadPlaybackState, ThreadPlaybackState, QAfterFilterCondition>
      compositeIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'compositeId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ThreadPlaybackState, ThreadPlaybackState, QAfterFilterCondition>
      compositeIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'compositeId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ThreadPlaybackState, ThreadPlaybackState, QAfterFilterCondition>
      compositeIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'compositeId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ThreadPlaybackState, ThreadPlaybackState, QAfterFilterCondition>
      compositeIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'compositeId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ThreadPlaybackState, ThreadPlaybackState, QAfterFilterCondition>
      compositeIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'compositeId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ThreadPlaybackState, ThreadPlaybackState, QAfterFilterCondition>
      compositeIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'compositeId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ThreadPlaybackState, ThreadPlaybackState, QAfterFilterCondition>
      compositeIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'compositeId',
        value: '',
      ));
    });
  }

  QueryBuilder<ThreadPlaybackState, ThreadPlaybackState, QAfterFilterCondition>
      compositeIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'compositeId',
        value: '',
      ));
    });
  }

  QueryBuilder<ThreadPlaybackState, ThreadPlaybackState, QAfterFilterCondition>
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

  QueryBuilder<ThreadPlaybackState, ThreadPlaybackState, QAfterFilterCondition>
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

  QueryBuilder<ThreadPlaybackState, ThreadPlaybackState, QAfterFilterCondition>
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

  QueryBuilder<ThreadPlaybackState, ThreadPlaybackState, QAfterFilterCondition>
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

  QueryBuilder<ThreadPlaybackState, ThreadPlaybackState, QAfterFilterCondition>
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

  QueryBuilder<ThreadPlaybackState, ThreadPlaybackState, QAfterFilterCondition>
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

  QueryBuilder<ThreadPlaybackState, ThreadPlaybackState, QAfterFilterCondition>
      currentSceneIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'currentSceneId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ThreadPlaybackState, ThreadPlaybackState, QAfterFilterCondition>
      currentSceneIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'currentSceneId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ThreadPlaybackState, ThreadPlaybackState, QAfterFilterCondition>
      currentSceneIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'currentSceneId',
        value: '',
      ));
    });
  }

  QueryBuilder<ThreadPlaybackState, ThreadPlaybackState, QAfterFilterCondition>
      currentSceneIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'currentSceneId',
        value: '',
      ));
    });
  }

  QueryBuilder<ThreadPlaybackState, ThreadPlaybackState, QAfterFilterCondition>
      cursorEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'cursor',
        value: value,
      ));
    });
  }

  QueryBuilder<ThreadPlaybackState, ThreadPlaybackState, QAfterFilterCondition>
      cursorGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'cursor',
        value: value,
      ));
    });
  }

  QueryBuilder<ThreadPlaybackState, ThreadPlaybackState, QAfterFilterCondition>
      cursorLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'cursor',
        value: value,
      ));
    });
  }

  QueryBuilder<ThreadPlaybackState, ThreadPlaybackState, QAfterFilterCondition>
      cursorBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'cursor',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ThreadPlaybackState, ThreadPlaybackState, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<ThreadPlaybackState, ThreadPlaybackState, QAfterFilterCondition>
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

  QueryBuilder<ThreadPlaybackState, ThreadPlaybackState, QAfterFilterCondition>
      idLessThan(
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

  QueryBuilder<ThreadPlaybackState, ThreadPlaybackState, QAfterFilterCondition>
      idBetween(
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

  QueryBuilder<ThreadPlaybackState, ThreadPlaybackState, QAfterFilterCondition>
      lastReadAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastReadAt',
      ));
    });
  }

  QueryBuilder<ThreadPlaybackState, ThreadPlaybackState, QAfterFilterCondition>
      lastReadAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastReadAt',
      ));
    });
  }

  QueryBuilder<ThreadPlaybackState, ThreadPlaybackState, QAfterFilterCondition>
      lastReadAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastReadAt',
        value: value,
      ));
    });
  }

  QueryBuilder<ThreadPlaybackState, ThreadPlaybackState, QAfterFilterCondition>
      lastReadAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastReadAt',
        value: value,
      ));
    });
  }

  QueryBuilder<ThreadPlaybackState, ThreadPlaybackState, QAfterFilterCondition>
      lastReadAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastReadAt',
        value: value,
      ));
    });
  }

  QueryBuilder<ThreadPlaybackState, ThreadPlaybackState, QAfterFilterCondition>
      lastReadAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastReadAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ThreadPlaybackState, ThreadPlaybackState, QAfterFilterCondition>
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

  QueryBuilder<ThreadPlaybackState, ThreadPlaybackState, QAfterFilterCondition>
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

  QueryBuilder<ThreadPlaybackState, ThreadPlaybackState, QAfterFilterCondition>
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

  QueryBuilder<ThreadPlaybackState, ThreadPlaybackState, QAfterFilterCondition>
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

  QueryBuilder<ThreadPlaybackState, ThreadPlaybackState, QAfterFilterCondition>
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

  QueryBuilder<ThreadPlaybackState, ThreadPlaybackState, QAfterFilterCondition>
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

  QueryBuilder<ThreadPlaybackState, ThreadPlaybackState, QAfterFilterCondition>
      saveSlotIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'saveSlotId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ThreadPlaybackState, ThreadPlaybackState, QAfterFilterCondition>
      saveSlotIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'saveSlotId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ThreadPlaybackState, ThreadPlaybackState, QAfterFilterCondition>
      saveSlotIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'saveSlotId',
        value: '',
      ));
    });
  }

  QueryBuilder<ThreadPlaybackState, ThreadPlaybackState, QAfterFilterCondition>
      saveSlotIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'saveSlotId',
        value: '',
      ));
    });
  }

  QueryBuilder<ThreadPlaybackState, ThreadPlaybackState, QAfterFilterCondition>
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

  QueryBuilder<ThreadPlaybackState, ThreadPlaybackState, QAfterFilterCondition>
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

  QueryBuilder<ThreadPlaybackState, ThreadPlaybackState, QAfterFilterCondition>
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

  QueryBuilder<ThreadPlaybackState, ThreadPlaybackState, QAfterFilterCondition>
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

  QueryBuilder<ThreadPlaybackState, ThreadPlaybackState, QAfterFilterCondition>
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

  QueryBuilder<ThreadPlaybackState, ThreadPlaybackState, QAfterFilterCondition>
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

  QueryBuilder<ThreadPlaybackState, ThreadPlaybackState, QAfterFilterCondition>
      threadIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'threadId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ThreadPlaybackState, ThreadPlaybackState, QAfterFilterCondition>
      threadIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'threadId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ThreadPlaybackState, ThreadPlaybackState, QAfterFilterCondition>
      threadIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'threadId',
        value: '',
      ));
    });
  }

  QueryBuilder<ThreadPlaybackState, ThreadPlaybackState, QAfterFilterCondition>
      threadIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'threadId',
        value: '',
      ));
    });
  }
}

extension ThreadPlaybackStateQueryObject on QueryBuilder<ThreadPlaybackState,
    ThreadPlaybackState, QFilterCondition> {}

extension ThreadPlaybackStateQueryLinks on QueryBuilder<ThreadPlaybackState,
    ThreadPlaybackState, QFilterCondition> {}

extension ThreadPlaybackStateQuerySortBy
    on QueryBuilder<ThreadPlaybackState, ThreadPlaybackState, QSortBy> {
  QueryBuilder<ThreadPlaybackState, ThreadPlaybackState, QAfterSortBy>
      sortByCompositeId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'compositeId', Sort.asc);
    });
  }

  QueryBuilder<ThreadPlaybackState, ThreadPlaybackState, QAfterSortBy>
      sortByCompositeIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'compositeId', Sort.desc);
    });
  }

  QueryBuilder<ThreadPlaybackState, ThreadPlaybackState, QAfterSortBy>
      sortByCurrentSceneId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentSceneId', Sort.asc);
    });
  }

  QueryBuilder<ThreadPlaybackState, ThreadPlaybackState, QAfterSortBy>
      sortByCurrentSceneIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentSceneId', Sort.desc);
    });
  }

  QueryBuilder<ThreadPlaybackState, ThreadPlaybackState, QAfterSortBy>
      sortByCursor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cursor', Sort.asc);
    });
  }

  QueryBuilder<ThreadPlaybackState, ThreadPlaybackState, QAfterSortBy>
      sortByCursorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cursor', Sort.desc);
    });
  }

  QueryBuilder<ThreadPlaybackState, ThreadPlaybackState, QAfterSortBy>
      sortByLastReadAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastReadAt', Sort.asc);
    });
  }

  QueryBuilder<ThreadPlaybackState, ThreadPlaybackState, QAfterSortBy>
      sortByLastReadAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastReadAt', Sort.desc);
    });
  }

  QueryBuilder<ThreadPlaybackState, ThreadPlaybackState, QAfterSortBy>
      sortBySaveSlotId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'saveSlotId', Sort.asc);
    });
  }

  QueryBuilder<ThreadPlaybackState, ThreadPlaybackState, QAfterSortBy>
      sortBySaveSlotIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'saveSlotId', Sort.desc);
    });
  }

  QueryBuilder<ThreadPlaybackState, ThreadPlaybackState, QAfterSortBy>
      sortByThreadId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'threadId', Sort.asc);
    });
  }

  QueryBuilder<ThreadPlaybackState, ThreadPlaybackState, QAfterSortBy>
      sortByThreadIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'threadId', Sort.desc);
    });
  }
}

extension ThreadPlaybackStateQuerySortThenBy
    on QueryBuilder<ThreadPlaybackState, ThreadPlaybackState, QSortThenBy> {
  QueryBuilder<ThreadPlaybackState, ThreadPlaybackState, QAfterSortBy>
      thenByCompositeId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'compositeId', Sort.asc);
    });
  }

  QueryBuilder<ThreadPlaybackState, ThreadPlaybackState, QAfterSortBy>
      thenByCompositeIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'compositeId', Sort.desc);
    });
  }

  QueryBuilder<ThreadPlaybackState, ThreadPlaybackState, QAfterSortBy>
      thenByCurrentSceneId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentSceneId', Sort.asc);
    });
  }

  QueryBuilder<ThreadPlaybackState, ThreadPlaybackState, QAfterSortBy>
      thenByCurrentSceneIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentSceneId', Sort.desc);
    });
  }

  QueryBuilder<ThreadPlaybackState, ThreadPlaybackState, QAfterSortBy>
      thenByCursor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cursor', Sort.asc);
    });
  }

  QueryBuilder<ThreadPlaybackState, ThreadPlaybackState, QAfterSortBy>
      thenByCursorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cursor', Sort.desc);
    });
  }

  QueryBuilder<ThreadPlaybackState, ThreadPlaybackState, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<ThreadPlaybackState, ThreadPlaybackState, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<ThreadPlaybackState, ThreadPlaybackState, QAfterSortBy>
      thenByLastReadAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastReadAt', Sort.asc);
    });
  }

  QueryBuilder<ThreadPlaybackState, ThreadPlaybackState, QAfterSortBy>
      thenByLastReadAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastReadAt', Sort.desc);
    });
  }

  QueryBuilder<ThreadPlaybackState, ThreadPlaybackState, QAfterSortBy>
      thenBySaveSlotId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'saveSlotId', Sort.asc);
    });
  }

  QueryBuilder<ThreadPlaybackState, ThreadPlaybackState, QAfterSortBy>
      thenBySaveSlotIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'saveSlotId', Sort.desc);
    });
  }

  QueryBuilder<ThreadPlaybackState, ThreadPlaybackState, QAfterSortBy>
      thenByThreadId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'threadId', Sort.asc);
    });
  }

  QueryBuilder<ThreadPlaybackState, ThreadPlaybackState, QAfterSortBy>
      thenByThreadIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'threadId', Sort.desc);
    });
  }
}

extension ThreadPlaybackStateQueryWhereDistinct
    on QueryBuilder<ThreadPlaybackState, ThreadPlaybackState, QDistinct> {
  QueryBuilder<ThreadPlaybackState, ThreadPlaybackState, QDistinct>
      distinctByCompositeId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'compositeId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ThreadPlaybackState, ThreadPlaybackState, QDistinct>
      distinctByCurrentSceneId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'currentSceneId',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ThreadPlaybackState, ThreadPlaybackState, QDistinct>
      distinctByCursor() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'cursor');
    });
  }

  QueryBuilder<ThreadPlaybackState, ThreadPlaybackState, QDistinct>
      distinctByLastReadAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastReadAt');
    });
  }

  QueryBuilder<ThreadPlaybackState, ThreadPlaybackState, QDistinct>
      distinctBySaveSlotId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'saveSlotId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ThreadPlaybackState, ThreadPlaybackState, QDistinct>
      distinctByThreadId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'threadId', caseSensitive: caseSensitive);
    });
  }
}

extension ThreadPlaybackStateQueryProperty
    on QueryBuilder<ThreadPlaybackState, ThreadPlaybackState, QQueryProperty> {
  QueryBuilder<ThreadPlaybackState, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<ThreadPlaybackState, String, QQueryOperations>
      compositeIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'compositeId');
    });
  }

  QueryBuilder<ThreadPlaybackState, String, QQueryOperations>
      currentSceneIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'currentSceneId');
    });
  }

  QueryBuilder<ThreadPlaybackState, int, QQueryOperations> cursorProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'cursor');
    });
  }

  QueryBuilder<ThreadPlaybackState, DateTime?, QQueryOperations>
      lastReadAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastReadAt');
    });
  }

  QueryBuilder<ThreadPlaybackState, String, QQueryOperations>
      saveSlotIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'saveSlotId');
    });
  }

  QueryBuilder<ThreadPlaybackState, String, QQueryOperations>
      threadIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'threadId');
    });
  }
}
