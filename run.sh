#!/usr/bin/env bash

clear
echo "Bash >= 4 is required"
bash --version
echo

MAVEN_OPTS="-Xms1024m -Xmx1024m -XX:MaxPermSize=512m"

# concatenates all lines of a file
concat_lines() {
  if [ -f "$1" ]; then
    echo "$(tr -s '\n' ' ' < "$1")"
  fi
}

function match_index()
{
  local pattern=$1
  local string=$2  
  local result=${string/${pattern}*/}

  [ ${#result} = ${#string} ] || echo ${#result}
}

JVM_CONFIG=$(concat_lines ".mvn/jvm.config")

echo JVM_CONFIG=$JVM_CONFIG
echo MAVEN_OPTS=$MAVEN_OPTS
echo

#Delcare JVM_CONFIG array
declare -A JVM_CONFIG_ARRAY
for valueOpt in $JVM_CONFIG
do
    #Split the valueOpt by space
    IFS== read key value <<< "$valueOpt"
    
    #If value is empty
    if [[ -z "$value" ]]; then

        #If the last letter is a char (its probably a Xms or Xmx value)
        lastIndex="$(( ${#key} - 1))"
        if [[ ${key:$lastIndex:1} = [a-z]* ]]; then
            echo "(jvm opts) $key has no value and a alpha at end, maybe its a Xms or Xmx value"

            indexOfNumber=$(match_index "[0-9]" $key)

            #Index of first number, split, first section is key, other is value
            JVM_CONFIG_ARRAY+=(["${key:0:$indexOfNumber}"]="${key:$indexOfNumber:${#key}}")
        fi
    else
        JVM_CONFIG_ARRAY+=(["$key="]=$value)
    fi
done

#Delcare MAVEN_OPTS array
declare -A MAVEN_OPTS_ARRAY
for valueOpt in $MAVEN_OPTS
do
    #Split the valueOpt by space
    IFS== read key value <<< "$valueOpt"

    #If value is empty
    if [[ -z "$value" ]]; then

        #If the last letter is a char (its probably a Xms512m or Xmx512m value)
        lastIndex="$(( ${#key} - 1))"
        if [[ ${key:$lastIndex:1} = [a-z]* ]]; then
            echo "(maven opts) $key has no value and a alpha at end, maybe its a Xms or Xmx value"

            indexOfNumber=$(match_index "[0-9]" $key)

            #Index of first number, split, first section is key, other is value
            MAVEN_OPTS_ARRAY+=(["${key:0:$indexOfNumber}"]="${key:$indexOfNumber:${#key}}")
        fi
    else
        MAVEN_OPTS_ARRAY+=(["$key="]=$value)
    fi
done

echo
echo "Size JVM_CONFIG_ARRAY: ${#JVM_CONFIG_ARRAY[@]}"
echo "Size MAVEN_OPTS_ARRAY: ${#MAVEN_OPTS_ARRAY[@]}"
echo

MAVEN_OPTS_FINAL=""
for key in "${!MAVEN_OPTS_ARRAY[@]}"
do
    if [[ -z "${JVM_CONFIG_ARRAY[$key]}" ]]; then
        echo $key not on config, using maveOpts ${MAVEN_OPTS_ARRAY[$key]}
        MAVEN_OPTS_FINAL+="$key${MAVEN_OPTS_ARRAY[$key]} "
    else
        echo $key on both, using maveOpts $key${MAVEN_OPTS_ARRAY[$key]}

        MAVEN_OPTS_FINAL+="$key${MAVEN_OPTS_ARRAY[$key]} "
      
        unset JVM_CONFIG_ARRAY[$key]
    fi
done

#Loop over JVM Config and add the rest to opts (these arnt on the maven opts, so can be added)
for key in "${!JVM_CONFIG_ARRAY[@]}"
do
    MAVEN_OPTS_FINAL+="$key${JVM_CONFIG_ARRAY[$key]} "
done

echo
echo MAVEN_OPTS_FINAL=$MAVEN_OPTS_FINAL
