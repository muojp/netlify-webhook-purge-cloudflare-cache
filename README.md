# Netlify webhook ==> purge-cache on Cloudflare 

## About

This Lambda application enables you to purge Cloudflare's cache automatically when website is deployed on Netlify.

Ref: https://b.muo.jp/2020/03/27/netlify-cloudflare-auto-purge.html

## Deployment

1. Ensure you are using ruby version 2.7.x

2. Install bundle

        $ gem install bundler -v "~> 1.17"

3. Install Ruby dependencies for this service

        $ bundle install

4. Download the Gems to the local vendor directory

        $ bundle install --deployment

5. Create the deployment package (note: if you don't have a S3 bucket, you need to create one):

        $ aws cloudformation package \
            --template-file template.yaml \
            --output-template-file serverless-output.yaml \
            --s3-bucket { your-bucket-name }
            
    Alternatively, if you have [SAM CLI](https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/serverless-sam-cli-install.html) installed, you can run the following command 
    which will do the same

        $ sam package \
            --template-file template.yaml \
            --output-template-file serverless-output.yaml \
            --s3-bucket { your-bucket-name }
            
6. Deploying your application

        $ aws cloudformation deploy --template-file serverless-output.yaml \
            --stack-name { your-stack-name } \
            --capabilities CAPABILITY_IAM
    
    Or use SAM CLI

        $ sam deploy \
            --template-file serverless-output.yaml \
            --stack-name { your-stack-name } \
            --capabilities CAPABILITY_IAM

7. Setup Environment variables on AWS Lambda

 - CLOUDFLARE_API_TOKEN
   - obtained from Cloudflare management console
 - ZONE_ID
   - zone ID of target website
 - NETLIFY_PRESHARED_KEY
   - secret token set on Netlify webhook

## License

Original sample project: https://github.com/aws-samples/serverless-sinatra-sample

This library is licensed under the Apache 2.0 License.
