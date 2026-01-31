# Graphviz Advanced Styling Test

Testing complex Graphviz features including colors, line styles, shapes, clusters, and more.

## System Architecture Diagram

```dot
digraph Architecture {
    // Graph settings
    rankdir=TB;
    fontname="Helvetica";
    fontsize=12;
    compound=true;
    splines=ortho;

    // Default node style
    node [
        fontname="Helvetica",
        fontsize=10,
        shape=box,
        style="rounded,filled",
        fillcolor="#e8f4f8",
        color="#2c3e50",
        penwidth=1.5
    ];

    // Default edge style
    edge [
        fontname="Helvetica",
        fontsize=9,
        color="#7f8c8d",
        penwidth=1.2
    ];

    // Client Layer
    subgraph cluster_clients {
        label="Client Layer";
        style="dashed,rounded";
        color="#3498db";
        bgcolor="#ecf0f1";
        fontcolor="#2980b9";

        web [label="Web App\n(React)", fillcolor="#61dafb", fontcolor="#282c34"];
        mobile [label="Mobile App\n(Swift/Kotlin)", fillcolor="#ff6b6b", fontcolor="white"];
        cli [label="CLI Tool", fillcolor="#2ecc71", fontcolor="white"];
    }

    // API Gateway
    subgraph cluster_gateway {
        label="API Gateway";
        style="filled,rounded";
        color="#9b59b6";
        bgcolor="#f5eef8";
        fontcolor="#8e44ad";

        nginx [label="Nginx\nLoad Balancer", shape=octagon, fillcolor="#269539", fontcolor="white"];
        auth [label="Auth\nMiddleware", shape=diamond, fillcolor="#f39c12", fontcolor="white"];
    }

    // Microservices
    subgraph cluster_services {
        label="Microservices";
        style="filled,rounded";
        color="#e74c3c";
        bgcolor="#fdedec";
        fontcolor="#c0392b";

        user_svc [label="User\nService", fillcolor="#3498db", fontcolor="white"];
        order_svc [label="Order\nService", fillcolor="#3498db", fontcolor="white"];
        payment_svc [label="Payment\nService", fillcolor="#3498db", fontcolor="white"];
        notify_svc [label="Notification\nService", fillcolor="#3498db", fontcolor="white"];
    }

    // Data Layer
    subgraph cluster_data {
        label="Data Layer";
        style="filled,rounded";
        color="#27ae60";
        bgcolor="#eafaf1";
        fontcolor="#1e8449";

        postgres [label="PostgreSQL", shape=cylinder, fillcolor="#336791", fontcolor="white"];
        redis [label="Redis\nCache", shape=cylinder, fillcolor="#d92b21", fontcolor="white"];
        kafka [label="Kafka\nQueue", shape=parallelogram, fillcolor="#231f20", fontcolor="white"];
        s3 [label="S3\nStorage", shape=folder, fillcolor="#ff9900", fontcolor="white"];
    }

    // External Services
    subgraph cluster_external {
        label="External Services";
        style="dotted,rounded";
        color="#95a5a6";
        bgcolor="#f8f9f9";
        fontcolor="#7f8c8d";

        stripe [label="Stripe", shape=component, fillcolor="#635bff", fontcolor="white"];
        twilio [label="Twilio", shape=component, fillcolor="#f22f46", fontcolor="white"];
        aws [label="AWS SES", shape=component, fillcolor="#ff9900", fontcolor="white"];
    }

    // Connections - Client to Gateway
    web -> nginx [style=solid, color="#3498db", penwidth=2];
    mobile -> nginx [style=solid, color="#e74c3c", penwidth=2];
    cli -> nginx [style=solid, color="#2ecc71", penwidth=2];

    // Gateway internal
    nginx -> auth [style=bold, color="#9b59b6"];

    // Auth to Services
    auth -> user_svc [style=solid, label="JWT"];
    auth -> order_svc [style=solid, label="JWT"];
    auth -> payment_svc [style=solid, label="JWT"];

    // Service to Service (async)
    order_svc -> notify_svc [style=dashed, color="#e67e22", label="async"];
    payment_svc -> notify_svc [style=dashed, color="#e67e22", label="async"];

    // Services to Data
    user_svc -> postgres [style=solid];
    user_svc -> redis [style=dotted, label="cache"];
    order_svc -> postgres [style=solid];
    order_svc -> kafka [style=dashed, label="events"];
    payment_svc -> postgres [style=solid];
    notify_svc -> kafka [style=dashed, label="consume"];

    // Services to External
    payment_svc -> stripe [style=bold, color="#635bff", label="payments"];
    notify_svc -> twilio [style=bold, color="#f22f46", label="SMS"];
    notify_svc -> aws [style=bold, color="#ff9900", label="email"];

    // Storage
    order_svc -> s3 [style=dotted, label="attachments"];
}
```

## State Machine with Colors

```dot
digraph StateMachine {
    rankdir=LR;
    fontname="Helvetica";

    node [fontname="Helvetica", fontsize=11];
    edge [fontname="Helvetica", fontsize=9];

    // Start/End states
    start [label="", shape=circle, width=0.3, style=filled, fillcolor=black];
    end [label="", shape=doublecircle, width=0.3, style=filled, fillcolor=black];

    // States with different colors
    idle [label="Idle", shape=ellipse, style=filled, fillcolor="#a8e6cf"];
    processing [label="Processing", shape=ellipse, style=filled, fillcolor="#ffd93d"];
    waiting [label="Waiting\nfor Input", shape=ellipse, style=filled, fillcolor="#6bcbff"];
    error [label="Error", shape=ellipse, style=filled, fillcolor="#ff6b6b", fontcolor=white];
    success [label="Success", shape=ellipse, style=filled, fillcolor="#6bcb77", fontcolor=white];

    // Transitions
    start -> idle;
    idle -> processing [label="start()"];
    processing -> waiting [label="needs_input", style=dashed];
    waiting -> processing [label="input_received"];
    processing -> success [label="complete", color="#2ecc71", penwidth=2];
    processing -> error [label="failure", color="#e74c3c", penwidth=2, style=dashed];
    error -> idle [label="retry()", style=dotted];
    success -> end;
    error -> end [label="abort()", style=dotted, color="#95a5a6"];
}
```

## Network Topology

```dot
graph Network {
    layout=neato;
    overlap=false;
    splines=true;

    node [fontname="Helvetica", fontsize=10];
    edge [fontname="Helvetica", fontsize=8];

    // Core routers
    core1 [label="Core\nRouter 1", shape=box3d, style=filled, fillcolor="#2c3e50", fontcolor=white];
    core2 [label="Core\nRouter 2", shape=box3d, style=filled, fillcolor="#2c3e50", fontcolor=white];

    // Distribution switches
    dist1 [label="Dist SW 1", shape=box, style="rounded,filled", fillcolor="#3498db", fontcolor=white];
    dist2 [label="Dist SW 2", shape=box, style="rounded,filled", fillcolor="#3498db", fontcolor=white];
    dist3 [label="Dist SW 3", shape=box, style="rounded,filled", fillcolor="#3498db", fontcolor=white];

    // Access switches
    acc1 [label="Access 1", shape=box, style=filled, fillcolor="#1abc9c", fontcolor=white];
    acc2 [label="Access 2", shape=box, style=filled, fillcolor="#1abc9c", fontcolor=white];
    acc3 [label="Access 3", shape=box, style=filled, fillcolor="#1abc9c", fontcolor=white];
    acc4 [label="Access 4", shape=box, style=filled, fillcolor="#1abc9c", fontcolor=white];

    // Servers
    srv1 [label="Server 1", shape=record, style=filled, fillcolor="#9b59b6", fontcolor=white];
    srv2 [label="Server 2", shape=record, style=filled, fillcolor="#9b59b6", fontcolor=white];

    // Connections with different styles
    core1 -- core2 [style=bold, color="#e74c3c", penwidth=3, label="10Gbps"];

    core1 -- dist1 [penwidth=2, color="#3498db"];
    core1 -- dist2 [penwidth=2, color="#3498db"];
    core2 -- dist2 [penwidth=2, color="#3498db"];
    core2 -- dist3 [penwidth=2, color="#3498db"];

    dist1 -- acc1 [style=dashed];
    dist1 -- acc2 [style=dashed];
    dist2 -- acc3 [style=dashed];
    dist3 -- acc4 [style=dashed];

    dist1 -- srv1 [style=bold, color="#9b59b6"];
    dist3 -- srv2 [style=bold, color="#9b59b6"];
}
```

## Entity Relationship Diagram

```dot
digraph ERD {
    rankdir=LR;
    fontname="Helvetica";
    node [shape=none, fontname="Helvetica"];
    edge [fontname="Helvetica", fontsize=9];

    users [label=<
        <TABLE BORDER="0" CELLBORDER="1" CELLSPACING="0" CELLPADDING="6">
            <TR><TD BGCOLOR="#3498db" COLSPAN="2"><FONT COLOR="white"><B>Users</B></FONT></TD></TR>
            <TR><TD ALIGN="LEFT">🔑 id</TD><TD ALIGN="LEFT">UUID</TD></TR>
            <TR><TD ALIGN="LEFT">email</TD><TD ALIGN="LEFT">VARCHAR(255)</TD></TR>
            <TR><TD ALIGN="LEFT">name</TD><TD ALIGN="LEFT">VARCHAR(100)</TD></TR>
            <TR><TD ALIGN="LEFT">created_at</TD><TD ALIGN="LEFT">TIMESTAMP</TD></TR>
        </TABLE>
    >];

    orders [label=<
        <TABLE BORDER="0" CELLBORDER="1" CELLSPACING="0" CELLPADDING="6">
            <TR><TD BGCOLOR="#2ecc71" COLSPAN="2"><FONT COLOR="white"><B>Orders</B></FONT></TD></TR>
            <TR><TD ALIGN="LEFT">🔑 id</TD><TD ALIGN="LEFT">UUID</TD></TR>
            <TR><TD ALIGN="LEFT">🔗 user_id</TD><TD ALIGN="LEFT">UUID</TD></TR>
            <TR><TD ALIGN="LEFT">status</TD><TD ALIGN="LEFT">ENUM</TD></TR>
            <TR><TD ALIGN="LEFT">total</TD><TD ALIGN="LEFT">DECIMAL</TD></TR>
            <TR><TD ALIGN="LEFT">created_at</TD><TD ALIGN="LEFT">TIMESTAMP</TD></TR>
        </TABLE>
    >];

    products [label=<
        <TABLE BORDER="0" CELLBORDER="1" CELLSPACING="0" CELLPADDING="6">
            <TR><TD BGCOLOR="#9b59b6" COLSPAN="2"><FONT COLOR="white"><B>Products</B></FONT></TD></TR>
            <TR><TD ALIGN="LEFT">🔑 id</TD><TD ALIGN="LEFT">UUID</TD></TR>
            <TR><TD ALIGN="LEFT">name</TD><TD ALIGN="LEFT">VARCHAR(200)</TD></TR>
            <TR><TD ALIGN="LEFT">price</TD><TD ALIGN="LEFT">DECIMAL</TD></TR>
            <TR><TD ALIGN="LEFT">stock</TD><TD ALIGN="LEFT">INTEGER</TD></TR>
        </TABLE>
    >];

    order_items [label=<
        <TABLE BORDER="0" CELLBORDER="1" CELLSPACING="0" CELLPADDING="6">
            <TR><TD BGCOLOR="#e74c3c" COLSPAN="2"><FONT COLOR="white"><B>Order Items</B></FONT></TD></TR>
            <TR><TD ALIGN="LEFT">🔑 id</TD><TD ALIGN="LEFT">UUID</TD></TR>
            <TR><TD ALIGN="LEFT">🔗 order_id</TD><TD ALIGN="LEFT">UUID</TD></TR>
            <TR><TD ALIGN="LEFT">🔗 product_id</TD><TD ALIGN="LEFT">UUID</TD></TR>
            <TR><TD ALIGN="LEFT">quantity</TD><TD ALIGN="LEFT">INTEGER</TD></TR>
            <TR><TD ALIGN="LEFT">price</TD><TD ALIGN="LEFT">DECIMAL</TD></TR>
        </TABLE>
    >];

    // Relationships
    users -> orders [label="1:N", style=bold, color="#3498db"];
    orders -> order_items [label="1:N", style=bold, color="#2ecc71"];
    products -> order_items [label="1:N", style=bold, color="#9b59b6"];
}
```

## Simple Decision Tree

```dot
digraph DecisionTree {
    rankdir=TB;
    fontname="Helvetica";
    node [fontname="Helvetica", fontsize=10];
    edge [fontname="Helvetica", fontsize=9];

    // Decision nodes (diamonds)
    q1 [label="Is it raining?", shape=diamond, style=filled, fillcolor="#ffeaa7"];
    q2 [label="Do you have\nan umbrella?", shape=diamond, style=filled, fillcolor="#ffeaa7"];
    q3 [label="Is it cold?", shape=diamond, style=filled, fillcolor="#ffeaa7"];

    // Action nodes (rounded boxes)
    a1 [label="Take umbrella\nand go outside", shape=box, style="rounded,filled", fillcolor="#55efc4"];
    a2 [label="Stay inside\nor get wet", shape=box, style="rounded,filled", fillcolor="#ff7675"];
    a3 [label="Wear a jacket", shape=box, style="rounded,filled", fillcolor="#74b9ff"];
    a4 [label="Enjoy the\nnice weather!", shape=box, style="rounded,filled", fillcolor="#55efc4"];

    // Edges with labels
    q1 -> q2 [label="Yes", color="#e74c3c"];
    q1 -> q3 [label="No", color="#27ae60"];
    q2 -> a1 [label="Yes", color="#27ae60"];
    q2 -> a2 [label="No", color="#e74c3c"];
    q3 -> a3 [label="Yes", color="#e74c3c"];
    q3 -> a4 [label="No", color="#27ae60"];
}
```
