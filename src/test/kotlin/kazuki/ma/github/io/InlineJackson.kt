package kazuki.ma.github.io

import com.fasterxml.jackson.annotation.JsonValue
import com.fasterxml.jackson.core.JsonParser
import com.fasterxml.jackson.core.Version
import com.fasterxml.jackson.databind.*
import com.fasterxml.jackson.databind.deser.Deserializers
import com.fasterxml.jackson.databind.deser.KeyDeserializers
import com.fasterxml.jackson.module.kotlin.readValue
import com.fasterxml.jackson.module.kotlin.registerKotlinModule
import org.junit.jupiter.api.Test
import kotlin.reflect.full.createType
import kotlin.reflect.full.primaryConstructor
import kotlin.reflect.jvm.isAccessible

annotation class EnableInlineClassDeserialize

private class InlineClassDeserializer(
    rawClass: Class<*>
) : JsonDeserializer<Any>() {
    private val const = rawClass.kotlin.primaryConstructor.apply { this!!.isAccessible = true }!!
    private val getter: (JsonParser) -> Any = when (const.parameters[0].type) {
        Boolean::class.createType() -> JsonParser::getValueAsBoolean
        Int::class.createType() -> JsonParser::getValueAsInt
        Long::class.createType() -> JsonParser::getValueAsLong
        Float::class.createType() -> JsonParser::getFloatValue
        Double::class.createType() -> JsonParser::getValueAsDouble
        else -> JsonParser::getValueAsString
    }

    override fun deserialize(p: JsonParser, ctxt: DeserializationContext): Any {
        return const.call(getter(p))
    }
}

private class InlineClassKeySerializer(
    rawClass: Class<*>
) : KeyDeserializer() {
    private val const = rawClass.kotlin.primaryConstructor.apply { this!!.isAccessible = true }!!
    override fun deserializeKey(key: String?, ctxt: DeserializationContext?): Any {
        return const.call(key)
    }
}

class KotlinInlineClassModule : Module() {
    override fun version() = Version.unknownVersion()
    override fun getModuleName() = javaClass.name

    override fun setupModule(context: Module.SetupContext) {
        context.addKeyDeserializers(KeyDeserializers { type, _, _ ->
            if (type.isInlineClass) {
                return@KeyDeserializers InlineClassKeySerializer(type.rawClass)
            }
            null
        })
        context.addDeserializers(object : Deserializers.Base() {
            override fun findBeanDeserializer(
                type: JavaType,
                config: DeserializationConfig?,
                beanDesc: BeanDescription?
            ): JsonDeserializer<*>? {
                if (type.isInlineClass) {
                    return InlineClassDeserializer(type.rawClass)
                }
                return null
            }
        })
    }

    private val JavaType.isInlineClass: Boolean
        get() = rawClass.isAnnotationPresent(EnableInlineClassDeserialize::class.java)
}


@EnableInlineClassDeserialize
inline class MyStringId(
    @get:JsonValue
    val value: String
)

@EnableInlineClassDeserialize
inline class MyLongId(
    @get:JsonValue
    val value: Long
)

class InlineJackson {
    companion object {
        private val log = mu.KotlinLogging.logger {}
    }

    private val mapper = ObjectMapper().registerKotlinModule()

    init {
        mapper.registerModule(KotlinInlineClassModule())
    }

    @Test
    fun testInlineSerialize() {
        val ret = mapper.writeValueAsString(MyStringId("test"))

        log.info { ret }

        val readValue = mapper.readValue(ret, MyStringId::class.java)
        val longValue = mapper.readValue("123", MyLongId::class.java)
        val mapValue = mapper.readValue<Map<MyStringId, MyLongId>>("""{"key": 1}""")
        val listValue = mapper.readValue<List<MyStringId>>("""["1","2"]""")

        log.info { readValue }
        log.info { longValue }
        log.info { mapValue }
        log.info { listValue }
    }
}