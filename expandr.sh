#! /bin/sh -f
#stride:
#0-key (dummy name)
#1-normal value for smudge
#2-prefix to sed s command (if necessary for lookahead exclusion)
#  2 is only used in live application name, this is a workaround
#  for if your application name is Application Name
#  and your staging application name is Application Name Staging
#
###-LIVE-VALUES-###
LIVE_AWS_ACCESS_KEY_ID[0]="@LIVE_AWS_ACCESS_KEY_ID@"
LIVE_AWS_ACCESS_KEY_ID[1]="fill in with real value"
LIVE_AWS_SECRET_ACCESS_KEY[0]="@LIVE_AWS_SECRET_ACCESS_KEY@"
LIVE_AWS_SECRET_ACCESS_KEY[1]="fill in with real value"
#this is the AWS application name
LIVE_APPLICATION_NAME[0]="@LIVE_APPLICATION_NAME@"
LIVE_APPLICATION_NAME[1]="fill in with real value"
LIVE_APPLICATION_NAME[2]="/fill in with staging app name value if it contains the live app name value/!"
LIVE_MERCHANT_ID[0]="@LIVE_MERCHANT_ID@"
LIVE_MERCHANT_ID[1]="fill in with real value"
#
###-SANDBOX-VALUES-###
SANDBOX_AWS_ACCESS_KEY_ID[0]="@TEST_AWS_ACCESS_KEY_ID@"
SANDBOX_AWS_ACCESS_KEY_ID[1]="fill in with real value"
SANDBOX_AWS_SECRET_ACCESS_KEY[0]="@TEST_AWS_SECRET_ACCESS_KEY@"
SANDBOX_AWS_SECRET_ACCESS_KEY[1]="fill in with real value"
SANDBOX_APPLICATION_NAME[0]="@TEST_APPLICATION_NAME@"
SANDBOX_APPLICATION_NAME[1]="fill in with real value"
SANDBOX_MERCHANT_ID[0]="@TEST_MERCHANT_ID@"
SANDBOX_MERCHANT_ID[1]="fill in with real value"
#
###-DB-###
MAIN_DB_DUMMY_NAME="@MAIN_DB_NAME@"
TESTS_DB_DUMMY_NAME="@TESTS_DB_NAME@"
LIVE_DB_NAME="fill in with real value"
STAGING_DB_NAME="fill in with real value"
TEST_DB_NAME="fill in with real value"
#
###-EMAIL-###
ADMIN_EMAIL[0]="@ADMIN_EMAIL@"
ADMIN_EMAIL[1]="fill in with real value"
#
###-FRAMEWORK-DIR-###
#
#here array members past [0] are 'old' values for cleaning only
FRAMEWORK_DIR_DUMMY_NAME="@DIR_FRAMEWORK@"
FRAMEWORK_DIR_LIVE="/insert/your/live/path/here"
FRAMEWORK_DIR_STAGING="/insert/your/staging/path/here"
FRAMEWORK_DIR_TEST="/insert/your/test/path/here"
FRAMEWORK_DIR_OLD="/insert/a/previous/path/here/for/cleansing/"
#
#
###-SED-ARGUMENTS-FUNCTIONS-###
# these escape your values
SED_SEPARATOR='|'
KEY_ESCAPE_ARG='s/[]\/'${SED_SEPARATOR}'$*.^|[]/\\&/g'
function sed_keyword_escape() {
    echo $1 | sed -e ${KEY_ESCAPE_ARG}
}
ESCAPED_SED_SEPARATOR=$(sed_keyword_escape $SED_SEPARATOR)
REPL_ESCAPE_ARG='s/['${ESCAPED_SED_SEPARATOR}'&]/\\&/g'
function sed_replacement_escape() {
    echo $1 | sed -e ${REPL_ESCAPE_ARG}
}
#
#
#
#
#
#
###-SMUDGE-FUNCTIONS-###
function framework_smudge() {
    FRAMEWORK_PATH=$(echo FRAMEWORK_DIR_${BRANCH} | tr "[:lower:]" "[:upper:]")
    sed \
    -e "s|${FRAMEWORK_DIR_DUMMY_NAME}|${!FRAMEWORK_PATH}|g" \
    $1
}
function accounts_smudge_live() {
    sed \
    -e "s|${LIVE_TD_USERNAME[0]}|${LIVE_TD_USERNAME[1]}|g" \
    -e "s|${LIVE_TD_PASSWORD[0]}|${LIVE_TD_PASSWORD[1]}|g" \
    -e "s|${LIVE_AWS_ACCESS_KEY_ID[0]}|${LIVE_AWS_ACCESS_KEY_ID[1]}|g" \
    -e "s|${LIVE_AWS_SECRET_ACCESS_KEY[0]}|$(sed_replacement_escape "${LIVE_AWS_SECRET_ACCESS_KEY[1]}")|g" \
    -e "s|${LIVE_APPLICATION_NAME[0]}|${LIVE_APPLICATION_NAME[1]}|g" \
    -e "s|${LIVE_MERCHANT_ID[0]}|${LIVE_MERCHANT_ID[1]}|g" \
    $1
}
function accounts_smudge_sandbox() {
   sed \
    -e "s|${SANDBOX_TD_USERNAME[0]}|${SANDBOX_TD_USERNAME[1]}|g" \
    -e "s|${SANDBOX_TD_PASSWORD[0]}|${SANDBOX_TD_PASSWORD[1]}|g" \
    -e "s|${SANDBOX_AWS_ACCESS_KEY_ID[0]}|${SANDBOX_AWS_ACCESS_KEY_ID[1]}|g" \
    -e "s|${SANDBOX_AWS_SECRET_ACCESS_KEY[0]}|$(sed_replacement_escape "${SANDBOX_AWS_SECRET_ACCESS_KEY[1]}")|g" \
    -e "s|${SANDBOX_APPLICATION_NAME[0]}|${SANDBOX_APPLICATION_NAME[1]}|g" \
    -e "s|${SANDBOX_MERCHANT_ID[0]}|${SANDBOX_MERCHANT_ID[1]}|g" \
    $1
}
function accounts_smudge() {
    case ${ACCOUNTS} in
        live)
            accounts_smudge_live $1
            ;;
        staging)
            accounts_smudge_sandbox $1
            ;;
        test)
            accounts_smudge_sandbox $1
            ;;
        sandbox)
            accounts_smudge_sandbox $1
            ;;
        both)
            accounts_smudge_live $1 | \
            accounts_smudge_sandbox
            ;;
    esac
}
function db_smudge() {
    DB_REAL_NAME=$(echo ${DB} | tr "[:lower:]" "[:upper:]")_DB_NAME
    sed \
    -e "s|${MAIN_DB_DUMMY_NAME}|${!DB_REAL_NAME}|g" \
    -e "s|${TESTS_DB_DUMMY_NAME}|${!DB_REAL_NAME}|g" \
    $1
}
function email_smudge() {
    sed \
    -e "s|${ADMIN_EMAIL[0]}|${ADMIN_EMAIL[1]}|g"
}
#
#
#
#
#
#
###-CLEAN-FUNCTIONS-###
function framework_clean() {
    sed \
    -e "s|$(sed_replacement_escape ${FRAMEWORK_DIR_LIVE})|${FRAMEWORK_DIR_DUMMY_NAME}|g" \
    -e "s|$(sed_replacement_escape ${FRAMEWORK_DIR_STAGING})|${FRAMEWORK_DIR_DUMMY_NAME}|g" \
    -e "s|$(sed_replacement_escape ${FRAMEWORK_DIR_TEST})|${FRAMEWORK_DIR_DUMMY_NAME}|g" \
    -e "s|$(sed_replacement_escape ${FRAMEWORK_DIR_OLD})|${FRAMEWORK_DIR_DUMMY_NAME}|g" \
    $1
}
function accounts_clean_live() {
    sed \
    -e "s|${LIVE_TD_USERNAME[1]}|${LIVE_TD_USERNAME[0]}|g" \
    -e "s|${LIVE_TD_PASSWORD[1]}|${LIVE_TD_PASSWORD[0]}|g" \
    -e "s|${LIVE_AWS_ACCESS_KEY_ID[1]}|${LIVE_AWS_ACCESS_KEY_ID[0]}|g" \
    -e "s|$(sed_keyword_escape "${LIVE_AWS_SECRET_ACCESS_KEY[1]}")|${LIVE_AWS_SECRET_ACCESS_KEY[0]}|g" \
    -e "${LIVE_APPLICATION_NAME[2]:-""}s|${LIVE_APPLICATION_NAME[1]}|${LIVE_APPLICATION_NAME[0]}|g" \
    -e "s|${LIVE_MERCHANT_ID[1]}|${LIVE_MERCHANT_ID[0]}|g" \
    $1
}
function accounts_clean_sandbox() {
    sed \
    -e "s|${SANDBOX_TD_USERNAME[1]}|${SANDBOX_TD_USERNAME[0]}|g" \
    -e "s|${SANDBOX_TD_PASSWORD[1]}|${SANDBOX_TD_PASSWORD[0]}|g" \
    -e "s|${SANDBOX_AWS_ACCESS_KEY_ID[1]}|${SANDBOX_AWS_ACCESS_KEY_ID[0]}|g" \
    -e "s|$(sed_keyword_escape "${SANDBOX_AWS_SECRET_ACCESS_KEY[1]}")|${SANDBOX_AWS_SECRET_ACCESS_KEY[0]}|g" \
    -e "s|${SANDBOX_APPLICATION_NAME[1]}|${SANDBOX_APPLICATION_NAME[0]}|g" \
    -e "s|${SANDBOX_MERCHANT_ID[1]}|${SANDBOX_MERCHANT_ID[0]}|g" \
    $1
}
function accounts_clean() {
    accounts_clean_live $1 | \
    accounts_clean_sandbox
}
function db_clean() {
    DB_DUMMY_NAME=$(echo ${DOMAIN} | tr "[:lower:]" "[:upper:]")_DB_DUMMY_NAME
    sed \
    -e "s|${LIVE_DB_NAME}|${!DB_DUMMY_NAME}|g" \
    -e "s|${STAGING_DB_NAME}|${!DB_DUMMY_NAME}|g" \
    -e "s|${TEST_DB_NAME}|${!DB_DUMMY_NAME}|g" \
    $1
}
function email_clean() {
    len=${#ADMIN_EMAIL[@]}
    ((len=len-1))
    if [ $1 -lt ${len} ]
    then
    	i=$1
    	((x=i+1))
        sed \
        -e "s|${ADMIN_EMAIL[$1]}|${ADMIN_EMAIL[0]}|g" $2 | email_clean $x
    else
		sed \
        -e "s|${ADMIN_EMAIL[$1]}|${ADMIN_EMAIL[0]}|g" $2
    fi
}
##uncomment the below commented section to cd to THIS script's dir, in case you want to include any files in its same directory (this was necessary on a Mac but some other systems have easier ways to do this)
#TARGET_FILE=$0
#cd `dirname $TARGET_FILE`
#TARGET_FILE=`basename $TARGET_FILE`
## Iterate down a (possible) chain of symlinks
#while [ -L "$TARGET_FILE" ]
#do
#    TARGET_FILE=`readlink $TARGET_FILE`
#    cd `dirname $TARGET_FILE`
#    TARGET_FILE=`basename $TARGET_FILE`
#done
## Compute the canonicalized name by finding the physical path
## for the directory we're in and appending the target file.
#PHYS_DIR=`pwd -P`
#cd $PHYS_DIR
ACTION=
ACCOUNTS=
DB=
DOMAIN=
GIT_INPUT=
BRANCH=
if [ $# -ne 0 ]
then
    while [ $# -gt 1 ]
    do
        case $1 in
            --action)
                shift
                ACTION=$1
                shift
                ;;
            --accounts)
                shift
                ACCOUNTS=$1
                shift
                ;;
            --db)
                shift
                DB=$1
                shift
                ;;
            --db-domain)
                shift
                DOMAIN=$1
                shift
                ;;
            --branch)
                shift
                BRANCH=$1
                shift
        esac
    done
fi
#
#
#
###-THE-MAIN-FILTER-###
function filter() {
    case ${ACTION} in
        smudge)
            accounts_smudge $1 | \
            db_smudge | \
            framework_smudge | \
            email_smudge
            ;;
        clean)
            accounts_clean $1 | \
            db_clean | \
            framework_clean | \
            email_clean 1
            ;;
    esac
}
GIT_INPUT=`cat; echo x`
FILTERED_OUTPUT=$(printf '%s' "$GIT_INPUT" | filter)
FILTERED_OUTPUT=${FILTERED_OUTPUT%x}
printf '%s' "$FILTERED_OUTPUT"