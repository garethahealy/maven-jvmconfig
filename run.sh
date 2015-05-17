#!/usr/bin/env bash

clear
echo "Bash >= 4 is required"
bash --version
echo

# concatenates all lines of a file
concat_lines() {
  if [ -f "$1" ]; then
    echo "$(tr -s '\n' ' ' < "$1")"
  fi
}

JVM_CONFIG=$(concat_lines ".mvn/jvm.config")

echo JVM_CONFIG=$JVM_CONFIG
echo MAVEN_OPTS=$MAVEN_OPTS
echo

#Delcare JVM_CONFIG array
declare -A JVM_CONFIG_ARRAY
for value in $JVM_CONFIG
do
    IFS== read key value <<< "$value"
    #if value is empty, and the last letter is a char (its probably a Xms or Xmx value)
    if [[ -z "$value" ]]; then
        lastIndex="$(( ${#key} - 1))"
        if [[ ${key:$lastIndex:1} = [a-z]* ]]; then
            echo "(jvm opts) $key has no value and a alpha at end, maybe its a Xms or Xmx value"

            JVM_CONFIG_ARRAY+=(["$key"]="")
        fi
    else
      JVM_CONFIG_ARRAY+=(["$key="]=$value)
    fi
done

echo

#Delcare MAVEN_OPTS array
declare -A MAVEN_OPTS_ARRAY
for valueOpt in $MAVEN_OPTS
do
    IFS== read key value <<< "$valueOpt"
    #if value is empty, and the last letter is a char (its probably a Xms or Xmx value)
    if [[ -z "$value" ]]; then
        lastIndex="$(( ${#key} - 1))"
        if [[ ${key:$lastIndex:1} = [a-z]* ]]; then
            echo "(maven opts) $key has no value and a alpha at end, maybe its a Xms or Xmx value"

            #index of
            MAVEN_OPTS_ARRAY+=(["$key"]="")
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
    valueToUse=""

    valueMavenOpt=${MAVEN_OPTS_ARRAY[$key]}
    valueJvm=${JVM_CONFIG_ARRAY[$key]}
    if [[ -z "$valueJvm" ]]; then
      echo not on config
      $valueToUse=$valueMavenOpt
    else
      echo on both
    fi

    #get the value from


    echo "$key$value"

   MAVEN_OPTS_FINAL+="$key$valueToUse "
done

echo
echo MAVEN_OPTS_FINAL=$MAVEN_OPTS_FINAL

MAVEN_OPTS="$JVM_CONFIG $MAVEN_OPTS"

echo
echo Concat: $MAVEN_OPTS


#split JVM_CONFIG ' ' and add to a map
#split MAVEN_OPTS ' ' and add to a map

#if it isnt on MAVEN_OPTS, use it
